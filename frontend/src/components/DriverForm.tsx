import React, { useState } from 'react';
import type { ChangeEvent, FormEvent } from 'react';
import axios from 'axios';
import { useTheme } from './ThemeContext';

interface Props {
  onDriverAdded: () => void;
}

export default function DriverForm({ onDriverAdded }: Props) {
  const [form, setForm] = useState({
    firstName: '',
    middleInitial: '',
    lastName: '',
    mdtUsername: '',
    password: '',
  });
  const { theme } = useTheme();
  const [loading, setLoading] = useState(false);

  function handleChange(e: ChangeEvent<HTMLInputElement>) {
    setForm({ ...form, [e.target.name]: e.target.value });
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      await axios.post(`${import.meta.env.VITE_API}/drivers`, form);
      onDriverAdded();
      setForm({
        firstName: '',
        middleInitial: '',
        lastName: '',
        mdtUsername: '',
        password: '',
      });
    } catch (err: unknown) {
      if (axios.isAxiosError(err)) {
        alert('Error: ' + err.response?.data?.error || 'Unknown error');
      } else {
        alert('Error: Unknown error occurred');
      }
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className={`bg-white dark:bg-gray-800 rounded-lg shadow-lg overflow-hidden transition-colors duration-200 ${theme === 'dark' ? 'text-white' : 'text-gray-800'}`}>
      <div className="bg-blue-600 dark:bg-blue-700 px-6 py-4">
        <h3 className="text-xl font-semibold text-white flex items-center">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
          </svg>
          Add New Driver
        </h3>
      </div>
      
      <form onSubmit={handleSubmit} className="p-6 space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="space-y-2">
            <label htmlFor="firstName" className="block text-sm font-medium">First Name</label>
            <input
              id="firstName"
              name="firstName"
              value={form.firstName}
              placeholder="Enter first name"
              onChange={handleChange}
              required
              className="w-full px-4 py-2 rounded-md border border-gray-300 dark:border-gray-700 
                         bg-white dark:bg-gray-700 focus:ring-2 focus:ring-blue-500 
                         focus:border-blue-500 outline-none transition-colors"
            />
          </div>
          
          <div className="space-y-2">
            <label htmlFor="middleInitial" className="block text-sm font-medium">Middle Initial</label>
            <input
              id="middleInitial"
              name="middleInitial"
              value={form.middleInitial}
              placeholder="MI"
              onChange={handleChange}
              maxLength={1}
              className="w-full px-4 py-2 rounded-md border border-gray-300 dark:border-gray-700 
                         bg-white dark:bg-gray-700 focus:ring-2 focus:ring-blue-500 
                         focus:border-blue-500 outline-none transition-colors"
            />
          </div>
        </div>
        
        <div className="space-y-2">
          <label htmlFor="lastName" className="block text-sm font-medium">Last Name</label>
          <input
            id="lastName"
            name="lastName"
            value={form.lastName}
            placeholder="Enter last name"
            onChange={handleChange}
            required
            className="w-full px-4 py-2 rounded-md border border-gray-300 dark:border-gray-700 
                       bg-white dark:bg-gray-700 focus:ring-2 focus:ring-blue-500 
                       focus:border-blue-500 outline-none transition-colors"
          />
        </div>
        
        <div className="space-y-2">
          <label htmlFor="mdtUsername" className="block text-sm font-medium">MDT Username</label>
          <input
            id="mdtUsername"
            name="mdtUsername"
            value={form.mdtUsername}
            placeholder="Enter MDT username"
            onChange={handleChange}
            required
            className="w-full px-4 py-2 rounded-md border border-gray-300 dark:border-gray-700 
                       bg-white dark:bg-gray-700 focus:ring-2 focus:ring-blue-500 
                       focus:border-blue-500 outline-none transition-colors"
          />
        </div>
        
        <div className="space-y-2">
          <label htmlFor="password" className="block text-sm font-medium">Password</label>
          <input
            id="password"
            name="password"
            type="password"
            value={form.password}
            placeholder="Enter password"
            onChange={handleChange}
            required
            className="w-full px-4 py-2 rounded-md border border-gray-300 dark:border-gray-700 
                       bg-white dark:bg-gray-700 focus:ring-2 focus:ring-blue-500 
                       focus:border-blue-500 outline-none transition-colors"
          />
        </div>
        
        <button 
          type="submit" 
          disabled={loading}
          className="w-full mt-6 px-6 py-3 bg-blue-600 hover:bg-blue-700 
                     text-white font-medium rounded-md shadow transition-colors 
                     focus:outline-none focus:ring-4 focus:ring-blue-500 focus:ring-opacity-50
                     disabled:bg-blue-400 disabled:cursor-not-allowed flex justify-center items-center"
        >
          {loading ? (
            <>
              <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Processing...
            </>
          ) : "Add Driver"}
        </button>
      </form>
    </div>
  );
}