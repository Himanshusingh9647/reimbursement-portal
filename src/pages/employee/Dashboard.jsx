import React, { useEffect, useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { useLanguage } from '../../contexts/LanguageContext';
import { getEmployeeDashboardStats } from '../../services/dashboard';
import { getRequestsByEmployee } from '../../services/requests';
import { getRateConfig } from '../../services/rateConfig';
import DataTable from '../../components/shared/DataTable';
import Badge from '../../components/shared/Badge';
import { FileText, AlertCircle, Plus, TrendingUp, CreditCard, Clock, Plane, Wifi, Car, Truck, Building2, Globe, ArrowRight } from 'lucide-react';
import { formatDate } from '../../utils/formatters';
import { useNavigate } from 'react-router-dom';

export default function Dashboard() {
  const { user } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();
  const [stats, setStats] = useState(null);
  const [recentRequests, setRecentRequests] = useState([]);
  const [policyRates, setPolicyRates] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function loadDashboard() {
      try {
        const dashboardStats = await getEmployeeDashboardStats(user.ghrId);
        const allRequests = await getRequestsByEmployee(user.ghrId);
        
        setStats(dashboardStats);
        
        const sorted = allRequests.sort((a, b) => new Date(b.submittedAt) - new Date(a.submittedAt));
        
        const needsAttention = sorted.filter(req => {
          if (req.stage === 'pre-approval' && req.preApprovalStatus === 'rejected') return true;
          if (req.stage === 'pre-approval' && req.preApprovalStatus === 'approved') return true;
          if (req.stage === 'settlement' && req.settlementStatus === 'rejected') return true;
          return false;
        }).map(req => ({ ...req, _needsAction: true }));

        const others = sorted.filter(req => !needsAttention.find(n => n.id === req.id));
        
        setRecentRequests([...needsAttention, ...others].slice(0, 7));

        // Load policy rates for quick reference
        const cl = user.clLevel || 'CL3';
        const [domesticPerDiem, domesticHotel, internetCap, carpoolCap, relocation] = await Promise.all([
          getRateConfig('DomesticPerDiem'),
          getRateConfig('DomesticHotel'),
          getRateConfig('InternetCap'),
          getRateConfig('carpool'),
          getRateConfig('relocation')
        ]);
        
        let perDiemRate = cl === 'CL3' ? domesticPerDiem?.rates?.['CL3']?.['under5']?.value : domesticPerDiem?.rates?.[cl]?.value;
        if (!perDiemRate) perDiemRate = domesticPerDiem?.rates?.['CL3']?.['under5']?.value;
        
        let hotelRate = cl === 'CL3' ? domesticHotel?.rates?.['CL3']?.['under5']?.[0] : domesticHotel?.rates?.[cl]?.[0];
        if (hotelRate === undefined) hotelRate = domesticHotel?.rates?.['CL3']?.['under5']?.[0];

        let intCap = internetCap?.rates?.[cl]?.value || 1500;

        setPolicyRates({
          perDiem: perDiemRate,
          hotelCap: hotelRate,
          internet: intCap,
          carpool: carpoolCap?.dailyCap || 1000,
          relocationBase: relocation?.baseAllowance || 50000
        });

      } catch (err) {
        console.error("Failed to load dashboard data", err);
        setError(err.message || "Failed to load dashboard data");
      } finally {
        setLoading(false);
      }
    }
    
    if (user) {
      loadDashboard();
    }
  }, [user]);

  if (loading) {
    return (
      <div className="p-6 animate-fade-in">
        <div className="animate-pulse space-y-6">
          <div className="h-20 bg-gray-100 dark:bg-slate-800 rounded-lg" />
          <div className="grid grid-cols-4 gap-4">
            {[1,2,3,4].map(i => <div key={i} className="h-28 bg-gray-100 dark:bg-slate-800 rounded-lg" />)}
          </div>
          <div className="h-64 bg-gray-100 dark:bg-slate-800 rounded-lg" />
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-6 animate-fade-in">
        <div className="bg-red-50 dark:bg-red-900/30 text-red-700 dark:text-red-400 p-4 rounded-md mb-4 flex items-center gap-2">
          <AlertCircle size={20} />
          <span>{error}</span>
        </div>
        <button 
          onClick={() => window.location.reload()} 
          className="px-4 py-2 bg-samsung-blue text-white rounded-md hover:bg-blue-700"
        >
          {t('common.tryAgain')}
        </button>
      </div>
    );
  }

  const columns = [
    { 
      key: 'id', 
      label: t('table.id'), 
      render: (val, row) => (
        <div className="flex items-center gap-2">
          {row._needsAction && <span className="w-2 h-2 rounded-full bg-status-rejected flex-shrink-0 animate-subtle-pulse" title="Needs Action" />}
          <span className={`font-mono text-xs ${row._needsAction ? "font-semibold" : ""}`}>{val.slice(0,12)}</span>
        </div>
      ) 
    },
    { key: 'type', label: t('table.type'), render: (val) => {
      const icons = { travel: Plane, 'internet-bill': Wifi, carpool: Car, relocation: Truck };
      const Icon = icons[val] || FileText;
      return (
        <div className="flex items-center gap-2">
          <Icon size={14} className="text-samsung-blue dark:text-blue-400" />
          <span>{val.charAt(0).toUpperCase() + val.slice(1).replace('-', ' ')}</span>
        </div>
      );
    }},
    { key: 'submittedAt', label: t('table.submitted'), isNumeric: true, render: (val) => formatDate(val) },
    { 
      key: 'dates', 
      label: 'Travel Dates', 
      render: (_, row) => {
        if (row.type === 'travel' && row.dates?.startDate && row.dates?.endDate) {
          return `${formatDate(row.dates.startDate)} – ${formatDate(row.dates.endDate)}`;
        }
        return '—';
      }
    },
    { 
      key: 'stage', 
      label: t('table.stage'), 
      render: (val, row) => {
        let status = 'pending';
        if (row.stage === 'draft') status = 'draft';
        else if (row.extensionStatus === 'pending') status = 'pending';
        else if (row.stage === 'pre-approval' && row.preApprovalStatus === 'approved') status = 'approved';
        else if (row.stage === 'pre-approval' && row.preApprovalStatus === 'rejected') status = 'rejected';
        else if (row.stage === 'settlement' && row.settlementStatus === 'approved') status = 'approved';
        else if (row.stage === 'settlement' && row.settlementStatus === 'rejected') status = 'rejected';
        return <Badge status={status}>{val}</Badge>;
      } 
    },
    {
      key: 'actions',
      label: '',
      render: (_, row) => {
        if (row.type === 'travel' && row.stage === 'pre-approval' && row.preApprovalStatus === 'approved' && !row.settlement) {
          return (
            <div className="flex gap-2 justify-end">
              <button 
                onClick={(e) => { e.stopPropagation(); navigate(`/new-request/travel/extend/${row.id}`); }}
                className="text-xs bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 border border-border dark:border-gray-600 px-3 py-1.5 rounded font-medium hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none"
              >
                {t('table.extend')}
              </button>
              <button 
                onClick={(e) => { e.stopPropagation(); navigate(`/requests/${row.id}/settlement`); }}
                className="text-xs bg-samsung-blue text-white px-3 py-1.5 rounded font-medium hover:bg-blue-800 focus:outline-none"
              >
                {t('table.settle')}
              </button>
            </div>
          );
        }
        return null;
      }
    }
  ];

  // Fixed: Use correct field names from backend API response
  const totalReqs = stats?.totalRequests ?? stats?.totalCount ?? 0;
  const pendingReqs = stats?.pending ?? stats?.pendingCount ?? 0;
  const approvedReqs = stats?.approved ?? stats?.approvedCount ?? 0;
  const totalReimbursed = stats?.totalReimbursed ?? 0;

  return (
    <div className="p-6 w-full max-w-none mx-auto flex flex-col gap-8 animate-fade-in">
      {/* Page Header */}
      <div className="pb-6 border-b border-border dark:border-gray-700 bg-gradient-to-b from-blue-50/30 dark:from-blue-900/10 to-transparent -mx-6 px-6 pt-4 flex justify-between items-end">
        <div>
          <h1 className="font-serif text-2xl font-semibold text-gray-900 dark:text-gray-100">{t('dashboard.welcome')} {user.name}</h1>
          <p className="text-sm font-mono tracking-wide uppercase text-gray-500 dark:text-gray-400 mt-1">{user.department || user.team} • {user.clLevel || 'Employee'}</p>
        </div>
        <button 
          onClick={() => navigate('/new-request')}
          className="hidden sm:flex items-center gap-2 bg-samsung-blue text-white px-5 py-2.5 rounded-md font-medium text-sm hover:bg-blue-800 hover:shadow-lg focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-samsung-blue"
        >
          <Plus size={16} /> {t('nav.newRequest')}
        </button>
      </div>
      
      {/* Stat Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div 
          className="relative overflow-hidden bg-white dark:bg-slate-800 border border-border dark:border-slate-700 rounded-xl p-6 cursor-pointer hover:shadow-lg hover:border-samsung-blue/30 dark:hover:border-blue-500/30 group"
          onClick={() => navigate('/requests')}
        >
          <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-samsung-blue to-blue-400" />
          <div className="font-serif text-4xl text-gray-900 dark:text-gray-100 group-hover:text-samsung-blue dark:group-hover:text-blue-400">{totalReqs}</div>
          <div className="font-mono text-[10px] tracking-wide uppercase text-gray-500 dark:text-slate-400 mt-2">{t('dashboard.totalRequests')}</div>
          <ArrowRight size={16} className="absolute bottom-4 right-4 text-gray-300 dark:text-slate-600 group-hover:text-samsung-blue dark:group-hover:text-blue-400" />
        </div>
        <div className="relative overflow-hidden bg-white dark:bg-slate-800 border border-border dark:border-slate-700 rounded-xl p-6">
          <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-status-pending to-amber-300" />
          <div className="font-serif text-4xl text-status-pending">{pendingReqs}</div>
          <div className="font-mono text-[10px] tracking-wide uppercase text-gray-500 dark:text-slate-400 mt-2">{t('dashboard.pendingReviews')}</div>
        </div>
        <div className="relative overflow-hidden bg-white dark:bg-slate-800 border border-border dark:border-slate-700 rounded-xl p-6">
          <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-status-approved to-emerald-300" />
          <div className="font-serif text-4xl text-status-approved">{approvedReqs}</div>
          <div className="font-mono text-[10px] tracking-wide uppercase text-gray-500 dark:text-slate-400 mt-2">{t('dashboard.approved')}</div>
        </div>
        <div className="relative overflow-hidden bg-white dark:bg-slate-800 border border-border dark:border-slate-700 rounded-xl p-6">
          <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-samsung-blue via-blue-400 to-indigo-400" />
          <div className="font-serif text-3xl text-gray-900 dark:text-gray-100">
            <span className="text-lg align-top">₹</span>{totalReimbursed.toLocaleString('en-IN')}
          </div>
          <div className="font-mono text-[10px] tracking-wide uppercase text-gray-500 dark:text-slate-400 mt-2">Total Reimbursed</div>
          <TrendingUp size={16} className="absolute bottom-4 right-4 text-green-400" />
        </div>
      </div>

      <div className="flex flex-col lg:flex-row gap-8">
        {/* Main Content Column */}
        <div className="flex-1 min-w-0 flex flex-col gap-8">
          
          {/* Recent Requests */}
          <div>
            <div className="flex items-end justify-between border-b border-border dark:border-slate-700 pb-2 mb-4">
              <h2 className="font-serif text-xl font-medium text-gray-900 dark:text-gray-100">{t('dashboard.recentRequests')}</h2>
              <button 
                onClick={() => navigate('/requests')}
                className="text-samsung-blue dark:text-blue-400 font-semibold text-sm hover:underline flex items-center gap-1"
              >
                {t('dashboard.viewAll')} <ArrowRight size={14} />
              </button>
            </div>
            <div className="bg-white dark:bg-slate-800 rounded-xl border border-border dark:border-slate-700 overflow-hidden shadow-sm">
              <DataTable 
                columns={columns} 
                data={recentRequests} 
                emptyMessage={t('table.noRecords')} 
                pagination={false}
                onRowClick={(row) => {
                  if (row.stage === 'draft') {
                    if (row.type === 'travel') navigate(`/new-request/travel?draftId=${row.id}`);
                    else if (row.type === 'internet-bill') navigate(`/new-request/internet?draftId=${row.id}`);
                    else if (row.type === 'carpool') navigate(`/new-request/carpool?draftId=${row.id}`);
                    else if (row.type === 'relocation') navigate(`/new-request/relocation?draftId=${row.id}`);
                  } else {
                    navigate(`/requests/${row.id}`);
                  }
                }}
              />
            </div>
            {recentRequests.some(r => r._needsAction) && (
              <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 flex items-center gap-1">
                <span className="w-2 h-2 rounded-full bg-status-rejected inline-block animate-subtle-pulse" /> 
                Indicates a request that requires your attention or has been rejected.
              </p>
            )}
          </div>
        </div>

        {/* Right Rail Column */}
        <div className="w-full lg:w-[360px] shrink-0 flex flex-col gap-8">

          {/* Policy Quick Reference */}
          <div>
            <h2 className="font-serif text-xl font-medium text-gray-900 dark:text-gray-100 pb-2 mb-4 border-b border-border dark:border-slate-700">{t('dashboard.policyQuickRef')}</h2>
            <div className="bg-white dark:bg-slate-800 rounded-xl border border-border dark:border-slate-700 shadow-sm overflow-hidden">
              <div className="bg-gradient-to-r from-samsung-blue/5 to-blue-50 dark:from-blue-900/20 dark:to-slate-800 px-5 py-3 border-b border-border dark:border-slate-700">
                <p className="text-xs font-mono uppercase tracking-wide text-gray-500 dark:text-slate-400">
                  {t('dashboard.applicableLimits')} <strong className="text-samsung-blue dark:text-blue-400">{user.clLevel || 'CL3'}</strong>
                </p>
              </div>
              
              <div className="flex flex-col text-sm divide-y divide-gray-100 dark:divide-slate-700">
                {[
                  { icon: Plane, label: t('dashboard.domesticPerDiem'), value: `₹${policyRates?.perDiem ?? '-'} ${t('dashboard.perDay')}` },
                  { icon: Building2, label: t('dashboard.domesticHotel'), value: policyRates?.hotelCap === null ? t('dashboard.actuals') : `₹${policyRates?.hotelCap ?? '-'} ${t('dashboard.perNight')}` },
                  { icon: Globe, label: t('dashboard.intlFlight'), value: t('dashboard.actuals'), isActuals: true },
                  { icon: Wifi, label: t('dashboard.internetMonthlyCap'), value: `₹${policyRates?.internet ?? '-'}` },
                  { icon: Car, label: t('dashboard.carpoolDailyCap'), value: `₹${policyRates?.carpool ?? '-'}` },
                  { icon: Truck, label: t('dashboard.relocationBase'), value: `₹${policyRates?.relocationBase?.toLocaleString('en-IN') ?? '-'}` },
                ].map(({ icon: Icon, label, value, isActuals }) => (
                  <div key={label} className="px-5 py-3 flex items-start justify-between hover:bg-gray-50 dark:hover:bg-slate-700/50">
                    <div className="flex items-center gap-2 text-gray-700 dark:text-slate-300">
                      <Icon size={16} className="text-samsung-blue dark:text-blue-400" />
                      <span>{label}</span>
                    </div>
                    <span className={`font-mono font-medium ${isActuals ? 'text-gray-500 dark:text-slate-400 uppercase tracking-wide text-xs' : 'text-gray-900 dark:text-gray-100'}`}>
                      {value}
                    </span>
                  </div>
                ))}
              </div>

              <div className="px-5 py-3 border-t border-border dark:border-slate-700">
                <button
                  onClick={() => navigate('/policy')}
                  className="text-samsung-blue dark:text-blue-400 text-sm font-semibold hover:underline flex items-center gap-1 w-full justify-center"
                >
                  View Full Policy <ArrowRight size={14} />
                </button>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
