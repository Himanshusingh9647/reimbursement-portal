import { get, post, del } from './httpClient';

export const getVaultFiles = async (empId) => {
  return get(`/api/my-files/${empId}`);
};

export const uploadVaultFile = async (empId, fileType, file) => {
  const formData = new FormData();
  formData.append('empId', empId);
  formData.append('fileType', fileType || 'other');
  formData.append('file', file);

  return post('/api/my-files/upload', formData);
};

export const deleteVaultFile = async (id) => {
  return del(`/api/my-files/${id}`);
};

/**
 * Downloads a vault file to the user's device.
 * Uses the backend download endpoint to get the file as a blob,
 * then triggers a browser download with the original filename.
 * @param {string} filePath - The file URL path (e.g., "/user-files/abc.pdf").
 * @param {string} fileName - The original filename to save as.
 */
export const downloadVaultFile = async (filePath, fileName) => {
  const baseUrl = window.__API_BASE_URL__ || 'http://localhost:5252';
  const downloadUrl = `${baseUrl}/api/files/download?path=${encodeURIComponent(filePath)}&fileName=${encodeURIComponent(fileName)}`;

  const response = await fetch(downloadUrl, { method: 'GET' });
  if (!response.ok) {
    throw new Error('Failed to download file');
  }

  const blob = await response.blob();
  const url = window.URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = fileName;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  window.URL.revokeObjectURL(url);
};
