import React from 'react';
import { useTheme } from '../ThemeContext';
import { Menu, Sun, Moon } from 'lucide-react'; // Importing icons from lucide-react

interface TopNavProps {
    toggleSidebar: () => void;
}

const TopNav: React.FC<TopNavProps> = ({ toggleSidebar }) => {
    const { theme, toggleTheme } = useTheme();

    return (
        // Top navigation bar with fixed position, background, shadow, flex layout,
        // padding, and transitions for responsiveness.
        <div className={`
            fixed top-0 right-0 left-0 md:left-64 h-16 bg-white dark:bg-zinc-800 shadow-md
            flex items-center justify-between px-6 transition-all duration-300 ease-in-out z-40
        `}>
            {/* Left section of the navigation bar */}
            <div className="flex items-center">
                {/* Menu toggle button for mobile/collapsed sidebar */}
                <button
                    onClick={toggleSidebar}
                    className="md:hidden p-2 rounded-full text-gray-700 dark:text-gray-200
                                hover:bg-gray-200 dark:hover:bg-zinc-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
                    aria-label="Toggle sidebar"
                >
                    <Menu className="w-6 h-6" /> {/* Menu icon */}
                </button>
                {/* Placeholder for potential branding or search bar */}
                <span className="text-xl font-bold text-gray-800 dark:text-gray-100 ml-4 hidden md:block">
                    Dashboard Overview
                </span>
            </div>

            {/* Right section of the navigation bar */}
            <div className="flex items-center space-x-4">
                {/* Theme toggle button */}
                <button
                    onClick={toggleTheme}
                    className="p-2 rounded-full text-gray-700 dark:text-gray-200
                               hover:bg-gray-200 dark:hover:bg-zinc-700 focus:outline-none focus:ring-2 focus:ring-blue-500
                               transition-colors duration-200 ease-in-out"
                    aria-label="Toggle theme"
                >
                    {theme === 'dark' ? <Sun className="w-6 h-6 text-yellow-400" /> : <Moon className="w-6 h-6 text-indigo-700" />}
                </button>

                {/* User profile section */}
                <div className="flex items-center space-x-2">
                    <span className="font-medium text-gray-800 dark:text-gray-100 hidden sm:block">Admin User</span>
                    {/* User avatar */}
                    <div className="w-9 h-9 rounded-full bg-blue-600 text-white
                                    flex items-center justify-center font-bold text-sm
                                    shadow-md">
                        AU
                    </div>
                </div>
            </div>
        </div>
    );
};

export default TopNav;
