import { get } from './httpClient';

/**
 * Returns dashboard statistics for a specific employee.
 *
 * @param {string} ghrId - Employee GHR ID.
 * @returns {Promise<object>} Stats including counts and total reimbursed.
 */
export const getEmployeeDashboardStats = async (ghrId) => {
  const normalizedId = String(ghrId).trim();
  return get(`/api/dashboard/employee/${normalizedId}`);
};

/**
 * Returns dashboard statistics for the finance team.
 * Includes aggregate counts across ALL requests and a pending-reviews count.
 *
 * @returns {Promise<object>} Finance dashboard stats.
 */
export const getFinanceDashboardStats = async () => {
  return get('/api/dashboard/finance');
};

/**
 * Returns dashboard statistics for the admin view.
 *
 * @returns {Promise<object>} Admin dashboard stats.
 */
export const getAdminDashboardStats = async () => {
  // Mock fallback until .NET backend implements admin dashboard
  return {
    employeeCount: 0,
    activePolicyCount: 0,
    monthlyVolume: 0,
    byAccess: {
      admin: 0,
      finance: 0,
      standard: 0,
    },
    byDepartment: {},
    totalRequests: 0,
  };
};
