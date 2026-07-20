import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../contexts/LanguageContext';
import { useTheme } from '../contexts/ThemeContext';
import FormField from '../components/shared/FormField';
import { Moon, Sun, Globe, AlertCircle } from 'lucide-react';

export default function Login() {
  const [ghrId, setGhrId] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const { login } = useAuth();
  const { t, lang, toggleLanguage } = useLanguage();
  const { theme, toggleTheme } = useTheme();
  const navigate = useNavigate();
  const location = useLocation();

  const from = location.state?.from?.pathname || '/dashboard';

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setIsLoading(true);

    try {
      await login(ghrId, password);
      navigate(from === '/login' ? '/' : from, { replace: true });
    } catch (err) {
      setError(err.message || 'Login failed. Please check your credentials.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-slate-900 p-6 relative overflow-hidden animate-fade-in">
      {/* Animated gradient background blobs */}
      <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-samsung-blue/10 dark:bg-blue-600/10 blur-[100px] animate-pulse pointer-events-none" style={{ animationDuration: '4s' }} />
      <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-blue-400/10 dark:bg-blue-400/10 blur-[100px] animate-pulse pointer-events-none" style={{ animationDuration: '5s' }} />

      {/* Theme & Language toggles */}
      <div className="fixed top-6 right-6 flex items-center gap-2 z-50 bg-white/50 dark:bg-slate-800/50 backdrop-blur-md p-1.5 rounded-full border border-white/20 dark:border-slate-700/50 shadow-sm">
        <button 
          onClick={toggleTheme} 
          className="p-2 rounded-full text-gray-500 dark:text-gray-400 hover:text-samsung-blue dark:hover:text-blue-400 hover:bg-white dark:hover:bg-slate-700 transition-all"
          title={theme === 'dark' ? t('common.lightMode') : t('common.darkMode')}
        >
          {theme === 'dark' ? <Sun size={18} /> : <Moon size={18} />}
        </button>
        <div className="w-px h-4 bg-gray-300 dark:bg-slate-600 mx-1" />
        <button 
          onClick={toggleLanguage} 
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-gray-500 dark:text-gray-400 hover:text-samsung-blue dark:hover:text-blue-400 hover:bg-white dark:hover:bg-slate-700 font-medium text-sm transition-all"
          title="Toggle Language"
        >
          <Globe size={16} />
          <span className="uppercase tracking-wide text-xs">{lang}</span>
        </button>
      </div>

      <div className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl p-10 rounded-2xl border border-white/40 dark:border-slate-700 shadow-2xl w-full max-w-[420px] relative z-10">
        <div className="text-center mb-10">
          <div className="w-16 h-16 bg-samsung-blue dark:bg-blue-600 text-white rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-lg rotate-3 transform transition-transform hover:rotate-0">
            <span className="font-serif text-3xl font-bold">S</span>
          </div>
          <h1 className="font-serif text-3xl font-semibold text-gray-900 dark:text-gray-100 mb-2">{t('login.title')}</h1>
          <p className="font-mono text-sm tracking-widest uppercase text-samsung-blue dark:text-blue-400 font-medium">{t('login.subtitle')}</p>
        </div>

        {error && (
          <div role="alert" className="bg-red-50 dark:bg-red-900/30 text-status-rejected p-4 rounded-xl mb-6 text-sm font-medium border border-red-100 dark:border-red-800/50 flex items-start gap-3 animate-fade-in">
            <div className="mt-0.5"><AlertCircle size={16} /></div>
            <div>{error}</div>
          </div>
        )}

        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
          <FormField
            id="ghrId"
            label={t('login.username')}
            type="text"
            value={ghrId}
            onChange={(e) => setGhrId(e.target.value)}
            required
            placeholder="e.g. emp001"
            className="rounded-xl border-gray-200 dark:border-slate-700 bg-gray-50/50 dark:bg-slate-900/50 focus:bg-white dark:focus:bg-slate-900"
          />

          <FormField
            id="password"
            label={t('login.password')}
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            className="rounded-xl border-gray-200 dark:border-slate-700 bg-gray-50/50 dark:bg-slate-900/50 focus:bg-white dark:focus:bg-slate-900"
          />

          <button
            type="submit"
            disabled={isLoading}
            className="w-full mt-4 py-3.5 bg-samsung-blue text-white rounded-xl text-sm font-semibold hover:bg-blue-800 hover:shadow-lg hover:-translate-y-0.5 disabled:opacity-70 disabled:cursor-not-allowed disabled:transform-none disabled:shadow-none focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-samsung-blue transition-all flex justify-center items-center gap-2"
          >
            {isLoading ? (
              <>
                <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                {t('login.signingIn')}
              </>
            ) : t('login.signIn')}
          </button>
        </form>
      </div>
    </div>
  );
}
