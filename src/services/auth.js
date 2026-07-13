import { post, setAuthToken } from './httpClient';

const SESSION_USER_KEY = 'sem_currentUser';
const SESSION_TOKEN_KEY = 'sem_authToken';

/**
 * Authenticates an employee by username and password.
 *
 * @param {string} ghrId - The employee's GHR ID.
 * @param {string} password - The employee's password.
 * @returns {Promise<{ employee: object, token: string }>} Authenticated session.
 * @throws {Error} If credentials are invalid.
 */
export const login = async (ghrId, password) => {
  const normalizedId = String(ghrId).trim();

  try {
    const payload = {
      username: normalizedId,
      password: password
    };
    
    // Call the real .NET backend
    const user = await post('/api/auth/login', payload);
    
    // The backend doesn't generate JWTs yet, so we mock a token to satisfy frontend logic
    const token = 'temp-backend-token';

    // Use token for future API requests
    setAuthToken(token);

    // Persist session in sessionStorage (tab-scoped)
    sessionStorage.setItem(SESSION_USER_KEY, JSON.stringify(user));
    sessionStorage.setItem(SESSION_TOKEN_KEY, token);

    // Also inject some missing frontend fields that the mock object had, if needed
    // The backend uses 'id', frontend sometimes uses 'ghrId'. Ensure 'ghrId' exists:
    const safeEmployee = { ...user, ghrId: user.id };
    sessionStorage.setItem(SESSION_USER_KEY, JSON.stringify(safeEmployee));

    return { employee: safeEmployee, token };
  } catch (err) {
    if (err.status === 401) {
      const error = new Error('Invalid credentials. Please try again.');
      error.code = 'AUTH_INVALID_PASSWORD';
      throw error;
    }
    throw err;
  }
};

/**
 * Clears the current session, effectively logging the user out.
 * @returns {Promise<void>}
 */
export const logout = async () => {
  sessionStorage.removeItem(SESSION_USER_KEY);
  sessionStorage.removeItem(SESSION_TOKEN_KEY);
  setAuthToken(null);
};

/**
 * Returns the currently logged-in user, or null if no session exists.
 * @returns {Promise<object|null>} Employee record (without password) or null.
 */
export const getCurrentUser = async () => {
  const stored = sessionStorage.getItem(SESSION_USER_KEY);
  const token = sessionStorage.getItem(SESSION_TOKEN_KEY);
  if (stored && token) {
    setAuthToken(token); // Ensure client has token on reload
    return JSON.parse(stored);
  }
  return null;
};

/**
 * Returns the current authentication token, or null if not logged in.
 * @returns {Promise<string|null>} Token string or null.
 */
export const getToken = async () => {
  return sessionStorage.getItem(SESSION_TOKEN_KEY) || null;
};
