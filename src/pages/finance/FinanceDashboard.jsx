import React, { useState, useEffect } from 'react';
import { getFinanceDashboardStats } from '../../services/dashboard';
import { getAllRequests } from '../../services/requests';
import { useNavigate } from 'react-router-dom';
import { FileStack, CheckCircle, ArrowRight, AlertCircle } from 'lucide-react';
import DataTable from '../../components/shared/DataTable';
import Badge from '../../components/shared/Badge';
import { formatDate } from '../../utils/formatters';

export default function FinanceDashboard() {
  const [stats, setStats] = useState(null);
  const [newRequests, setNewRequests] = useState([]);
  const [processedRequests, setProcessedRequests] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    async function loadData() {
      try {
        const [statsData, requestsData] = await Promise.all([
          getFinanceDashboardStats(),
          getAllRequests()
        ]);
        setStats(statsData);

        const sorted = requestsData.sort((a, b) => new Date(b.submittedAt) - new Date(a.submittedAt));
        
        const newReqs = [];
        const procReqs = [];

        sorted.forEach(row => {
          let status = 'pending';
          if (row.stage === 'pre-approval' && row.preApprovalStatus === 'approved') status = 'approved';
          if (row.stage === 'pre-approval' && row.preApprovalStatus === 'rejected') status = 'rejected';
          if (row.stage === 'settlement' && row.settlementStatus === 'approved') status = 'approved';
          if (row.stage === 'settlement' && row.settlementStatus === 'rejected') status = 'rejected';

          if (status === 'pending') {
            newReqs.push(row);
          } else {
            procReqs.push(row);
          }
        });

        setNewRequests(newReqs);
        setProcessedRequests(procReqs);

      } catch (err) {
        console.error("Failed to load finance dashboard data", err);
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, []);

  if (loading) return <div className="p-6">Loading dashboard...</div>;

  const columns = [
    { key: 'id', label: 'ID', isNumeric: true, render: (val) => val.slice(0,8) },
    { key: 'ghrId', label: 'GHR ID', isNumeric: true },
    { key: 'type', label: 'Type', render: (val) => val.charAt(0).toUpperCase() + val.slice(1) },
    { key: 'submittedAt', label: 'Submitted Date', isNumeric: true, render: (val) => formatDate(val) },
    { 
      key: 'stage', 
      label: 'Stage', 
      render: (val, row) => {
        let status = 'pending';
        if (row.stage === 'pre-approval' && row.preApprovalStatus === 'approved') status = 'approved';
        if (row.stage === 'pre-approval' && row.preApprovalStatus === 'rejected') status = 'rejected';
        if (row.stage === 'settlement' && row.settlementStatus === 'approved') status = 'approved';
        if (row.stage === 'settlement' && row.settlementStatus === 'rejected') status = 'rejected';
        return <Badge status={status}>{val}</Badge>;
      } 
    },
  ];

  return (
    <div className="p-6 w-full max-w-none mx-auto flex flex-col gap-8">
      {/* Page Header */}
      <div className="pb-6 border-b border-border bg-gradient-to-b from-blue-50/30 dark:from-blue-900/20 to-transparent -mx-6 px-6 pt-4">
        <h1 className="font-serif text-2xl font-semibold text-gray-900 dark:text-white">Finance Dashboard</h1>
        <p className="text-sm font-mono tracking-wide uppercase text-gray-500 dark:text-gray-400 mt-1">Overview of portal activity and pending settlements</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {/* Review Queue Card */}
        <div className="bg-white dark:bg-gray-800 p-8 rounded-lg border-t-4 border-samsung-blue border-l border-r border-b border-border shadow-sm flex flex-col items-start gap-4">
          <div className="flex items-center gap-2 text-samsung-blue">
            <AlertCircle size={20} />
            <h2 className="font-serif text-xl font-medium text-gray-900 dark:text-white m-0">Needs Your Attention</h2>
          </div>
          
          <div className="my-6">
            <div className="font-serif text-6xl font-bold leading-none text-gray-900 dark:text-white">
              {stats?.pendingReviews || 0}
            </div>
            <div className="font-mono text-[10px] tracking-wide uppercase text-gray-500 dark:text-gray-400 mt-3">
              Requests pending finance review
            </div>
          </div>
        </div>

        {/* Other Stats */}
        <div className="flex flex-col gap-8">
          <div className="flex flex-col items-center justify-center bg-white dark:bg-gray-800 border border-border rounded-lg shadow-sm flex-1 p-8">
            <div className="font-serif text-5xl text-status-approved">{stats?.approvedToday || 0}</div>
            <div className="font-mono text-[10px] tracking-wide uppercase text-gray-500 dark:text-gray-400 mt-3">Approved Today</div>
          </div>
          <div className="flex flex-col items-center justify-center bg-white dark:bg-gray-800 border border-border rounded-lg shadow-sm flex-1 p-8">
            <div className="font-serif text-5xl text-gray-900 dark:text-white">{stats?.totalRequests || 0}</div>
            <div className="font-mono text-[10px] tracking-wide uppercase text-gray-500 dark:text-gray-400 mt-3">Total Request Volume</div>
          </div>
        </div>
      </div>

      {/* New Requests Section */}
      <div className="mt-4">
        <h2 className="font-serif text-xl font-semibold text-gray-900 dark:text-white mb-4">New Requests (Pending)</h2>
        <div className="bg-white dark:bg-gray-800 rounded-md border border-border overflow-hidden shadow-sm">
          <DataTable 
            columns={columns} 
            data={newRequests} 
            emptyMessage="No pending requests."
            onRowClick={(row) => navigate(`/finance/requests/${row.id}`)}
          />
        </div>
      </div>

      {/* Processed Requests Section */}
      <div className="mt-4">
        <h2 className="font-serif text-xl font-semibold text-gray-900 dark:text-white mb-4">Processed Requests</h2>
        <div className="bg-white dark:bg-gray-800 rounded-md border border-border overflow-hidden shadow-sm">
          <DataTable 
            columns={columns} 
            data={processedRequests} 
            emptyMessage="No processed requests."
            onRowClick={(row) => navigate(`/finance/requests/${row.id}`)}
          />
        </div>
      </div>
    </div>
  );
}
