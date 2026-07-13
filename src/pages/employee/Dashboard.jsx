import React, { useEffect, useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { getEmployeeDashboardStats } from '../../services/dashboard';
import { getRequestsByEmployee } from '../../services/requests';
import { getRateConfig, getIntlCountryTiers } from '../../services/rateConfig';
import DataTable from '../../components/shared/DataTable';
import Badge from '../../components/shared/Badge';
import { FileText, AlertCircle, Plus, Activity, TrendingUp, CreditCard, Clock, Plane, Wifi, Car, Truck, Shield, CheckCircle, Building2, Globe } from 'lucide-react';
import { formatDate } from '../../utils/formatters';
import { useNavigate } from 'react-router-dom';

export default function Dashboard() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [stats, setStats] = useState(null);
  const [recentRequests, setRecentRequests] = useState([]);
  const [recentActivity, setRecentActivity] = useState([]);
  const [policyRates, setPolicyRates] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function loadDashboard() {
      try {
        const dashboardStats = await getEmployeeDashboardStats(user.ghrId);
        const allRequests = await getRequestsByEmployee(user.ghrId);
        
        setStats(dashboardStats);
        
        // Sort by submittedAt
        const sorted = allRequests.sort((a, b) => new Date(b.submittedAt) - new Date(a.submittedAt));
        
        // Separate needs attention
        const needsAttention = sorted.filter(req => {
          if (req.stage === 'pre-approval' && req.preApprovalStatus === 'rejected') return true;
          if (req.stage === 'pre-approval' && req.preApprovalStatus === 'approved') return true;
          if (req.stage === 'settlement' && req.settlementStatus === 'rejected') return true;
          return false;
        }).map(req => ({ ...req, _needsAction: true }));

        const others = sorted.filter(req => !needsAttention.find(n => n.id === req.id));
        
        // Combine with needs attention at top
        setRecentRequests([...needsAttention, ...others].slice(0, 7));

        // Generate Recent Activity Feed (Derived from status/dates)
        const activityFeed = [];
        sorted.slice(0, 8).forEach(req => {
          const typeName = req.type.charAt(0).toUpperCase() + req.type.slice(1);
          if (req.settlementStatus === 'approved') {
            activityFeed.push({ id: req.id, text: `${typeName} settlement approved`, date: new Date(req.submittedAt).getTime() + 86400000 * 2, icon: CreditCard, color: 'text-green-600', bg: 'bg-green-50' });
          } else if (req.preApprovalStatus === 'approved') {
            activityFeed.push({ id: req.id, text: `${typeName} pre-approval granted`, date: new Date(req.submittedAt).getTime() + 86400000, icon: AlertCircle, color: 'text-blue-600', bg: 'bg-blue-50' });
          } else if (req.settlementStatus === 'pending') {
            activityFeed.push({ id: req.id, text: `${typeName} settlement submitted`, date: new Date(req.submittedAt).getTime() + 43200000, icon: Clock, color: 'text-orange-600', bg: 'bg-orange-50' });
          }
          activityFeed.push({ id: req.id + '_sub', text: `${typeName} request drafted`, date: new Date(req.submittedAt).getTime(), icon: FileText, color: 'text-gray-600', bg: 'bg-gray-100' });
        });
        
        setRecentActivity(activityFeed.sort((a, b) => b.date - a.date).slice(0, 6));

        // Load Policies
        const cl = user.clLevel || 'CL3';
        const [domesticPerDiem, domesticHotel, internetCap, carpoolCap, relocation] = await Promise.all([
          getRateConfig('domesticPerDiem'),
          getRateConfig('domesticHotel'),
          getRateConfig('internetCap'),
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
    return <div className="p-6">Loading dashboard...</div>;
  }

  if (error) {
    return (
      <div className="p-6">
        <div className="bg-red-50 text-red-700 p-4 rounded-md mb-4 flex items-center gap-2">
          <AlertCircle size={20} />
          <span>{error}</span>
        </div>
        <button 
          onClick={() => window.location.reload()} 
          className="px-4 py-2 bg-samsung-blue text-white rounded-md hover:bg-blue-700 transition-colors"
        >
          Try Again
        </button>
      </div>
    );
  }

  const columns = [
    { 
      key: 'id', 
      label: 'ID', 
      render: (val, row) => (
        <div className="flex items-center gap-2">
          {row._needsAction && <span className="w-2 h-2 rounded-full bg-status-rejected flex-shrink-0" title="Needs Action" />}
          <span className={row._needsAction ? "font-semibold" : ""}>{val.slice(0,8)}</span>
        </div>
      ) 
    },
    { key: 'type', label: 'Type', render: (val) => val.charAt(0).toUpperCase() + val.slice(1) },
    { key: 'submittedAt', label: 'Submitted', isNumeric: true, render: (val) => formatDate(val) },
    { 
      key: 'stage', 
      label: 'Stage', 
      render: (val, row) => {
        let status = 'pending';
        if (row.stage === 'draft') status = 'draft';
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
                className="text-xs bg-white text-gray-700 border border-border px-3 py-1.5 rounded font-medium hover:bg-gray-50 focus:outline-none"
              >
                Extend
              </button>
              <button 
                onClick={(e) => { e.stopPropagation(); navigate(`/requests/${row.id}/settlement`); }}
                className="text-xs bg-samsung-blue text-white px-3 py-1.5 rounded font-medium hover:bg-blue-800 focus:outline-none"
              >
                Settle
              </button>
            </div>
          );
        }
        return null;
      }
    }
  ];

  // Static spend summary data for the visual
  const spendCategories = [
    { label: 'Travel', claimed: 125000, approved: 125000, color: 'bg-blue-500' },
    { label: 'Internet', claimed: 6000, approved: 4500, color: 'bg-indigo-500' },
    { label: 'Carpool', claimed: 24000, approved: 22000, color: 'bg-teal-500' },
    { label: 'Relocation', claimed: 0, approved: 0, color: 'bg-purple-500' }
  ];
  const totalClaimed = spendCategories.reduce((acc, curr) => acc + curr.claimed, 0);
  const totalApproved = spendCategories.reduce((acc, curr) => acc + curr.approved, 0);

  return (
    <div className="p-6 w-full max-w-none mx-auto flex flex-col gap-8">
      {/* Page Header */}
      <div className="pb-6 border-b border-border bg-gradient-to-b from-blue-50/30 to-transparent -mx-6 px-6 pt-4 flex justify-between items-end">
        <div>
          <h1 className="font-serif text-2xl font-semibold text-gray-900">Welcome back, {user.name}</h1>
          <p className="text-sm font-mono tracking-wide uppercase text-gray-500 mt-1">{user.role} • {user.department || user.team}</p>
        </div>
        <button 
          onClick={() => navigate('/new-request')}
          className="hidden sm:flex items-center gap-2 bg-samsung-blue text-white px-5 py-2.5 rounded-md font-medium text-sm hover:bg-blue-800 focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-samsung-blue"
        >
          <Plus size={16} /> New Request
        </button>
      </div>
      
      {/* Flat Stat Row */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center divide-y sm:divide-y-0 sm:divide-x divide-border border border-border rounded-lg bg-white overflow-hidden shadow-sm">
        <div 
          className="flex-1 py-6 px-8 flex flex-col items-center justify-center cursor-pointer hover:bg-gray-50 transition-colors" 
          onClick={() => navigate('/requests')}
        >
          <div className="font-serif text-4xl text-gray-900">{stats?.totalCount || 0}</div>
          <div className="font-mono text-[10px] tracking-wide uppercase text-gray-500 mt-2">Total Requests</div>
        </div>
        <div className="flex-1 py-6 px-8 flex flex-col items-center justify-center">
          <div className="font-serif text-4xl text-gray-900">{stats?.pendingCount || 0}</div>
          <div className="font-mono text-[10px] tracking-wide uppercase text-gray-500 mt-2">Pending Reviews</div>
        </div>
        <div className="flex-1 py-6 px-8 flex flex-col items-center justify-center">
          <div className="font-serif text-4xl text-status-approved">{stats?.approvedCount || 0}</div>
          <div className="font-mono text-[10px] tracking-wide uppercase text-gray-500 mt-2">Approved</div>
        </div>
        <div className="flex-1 py-6 px-8 flex flex-col items-center justify-center">
          <div className="font-serif text-4xl text-status-rejected">{stats?.rejectedCount || 0}</div>
          <div className="font-mono text-[10px] tracking-wide uppercase text-gray-500 mt-2">Rejected</div>
        </div>
      </div>

      <div className="flex flex-col lg:flex-row gap-8">
        {/* Main Content Column */}
        <div className="flex-1 min-w-0 flex flex-col gap-8">
          
          {/* Recent Requests */}
          <div>
            <div className="flex items-end justify-between border-b border-border pb-2 mb-4">
              <h2 className="font-serif text-xl font-medium text-gray-900">Recent Requests</h2>
              <button 
                onClick={() => navigate('/requests')}
                className="text-samsung-blue font-semibold text-sm hover:underline"
              >
                View All
              </button>
            </div>
            <div className="bg-white rounded-md border border-border overflow-hidden">
              <DataTable 
                columns={columns} 
                data={recentRequests} 
                emptyMessage="No recent requests found" 
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
              <p className="text-xs text-gray-500 mt-2 flex items-center gap-1">
                <span className="w-2 h-2 rounded-full bg-status-rejected inline-block"></span> 
                Indicates a request that requires your attention or has been rejected.
              </p>
            )}
          </div>
        </div>

        {/* Right Rail Column */}
        <div className="w-full lg:w-[360px] shrink-0 flex flex-col gap-8">

          {/* Expanded Policy Quick Reference */}
          <div>
            <h2 className="font-serif text-xl font-medium text-gray-900 pb-2 mb-4 border-b border-border">Policy Quick Reference</h2>
            <div className="bg-white rounded-lg border border-border shadow-sm overflow-hidden">
              <div className="bg-gray-50 px-5 py-3 border-b border-border">
                <p className="text-xs font-mono uppercase tracking-wide text-gray-500">
                  Applicable limits for <strong className="text-gray-700">{user.clLevel || 'CL3'}</strong>
                </p>
              </div>
              
              <div className="flex flex-col text-sm divide-y divide-gray-100">
                <div className="px-5 py-3 flex items-start justify-between hover:bg-gray-50 transition-colors">
                  <div className="flex items-center gap-2 text-gray-700">
                    <Plane size={16} className="text-samsung-blue" />
                    <span>Domestic Per Diem</span>
                  </div>
                  <span className="font-mono font-medium text-gray-900">₹{policyRates?.perDiem ?? '-'} / day</span>
                </div>
                <div className="px-5 py-3 flex items-start justify-between hover:bg-gray-50 transition-colors">
                  <div className="flex items-center gap-2 text-gray-700">
                    <Building2 size={16} className="text-samsung-blue" />
                    <span>Domestic Hotel (Tier A+)</span>
                  </div>
                  <span className="font-mono font-medium text-gray-900">{policyRates?.hotelCap === null ? 'Actuals' : `₹${policyRates?.hotelCap ?? '-'} / night`}</span>
                </div>
                <div className="px-5 py-3 flex items-start justify-between hover:bg-gray-50 transition-colors">
                  <div className="flex items-center gap-2 text-gray-700">
                    <Globe size={16} className="text-samsung-blue" />
                    <span>International Flight</span>
                  </div>
                  <span className="font-mono font-medium text-gray-500 uppercase tracking-wide text-xs">Actuals</span>
                </div>
                
                <div className="px-5 py-3 flex items-start justify-between hover:bg-gray-50 transition-colors">
                  <div className="flex items-center gap-2 text-gray-700">
                    <Wifi size={16} className="text-samsung-blue" />
                    <span>Internet Monthly Cap</span>
                  </div>
                  <span className="font-mono font-medium text-gray-900">₹{policyRates?.internet ?? '-'}</span>
                </div>
                
                <div className="px-5 py-3 flex items-start justify-between hover:bg-gray-50 transition-colors">
                  <div className="flex items-center gap-2 text-gray-700">
                    <Car size={16} className="text-samsung-blue" />
                    <span>Carpool Daily Cap</span>
                  </div>
                  <span className="font-mono font-medium text-gray-900">₹{policyRates?.carpool ?? '-'}</span>
                </div>
                
                <div className="px-5 py-3 flex items-start justify-between hover:bg-gray-50 transition-colors">
                  <div className="flex items-center gap-2 text-gray-700">
                    <Truck size={16} className="text-samsung-blue" />
                    <span>Relocation Base</span>
                  </div>
                  <span className="font-mono font-medium text-gray-900">₹{policyRates?.relocationBase?.toLocaleString('en-IN') ?? '-'}</span>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
