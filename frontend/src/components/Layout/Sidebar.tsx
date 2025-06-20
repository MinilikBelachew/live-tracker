import React from 'react';
import { NavLink } from 'react-router-dom';
import { useTheme } from '../ThemeContext';
import { LayoutDashboard, Users, MapPin } from 'lucide-react'; // Importing icons from lucide-react

const Sidebar: React.FC = () => {
    const { theme } = useTheme();

    return (
        // Sidebar container with fixed position, full height, width, padding, background,
        // shadow, and responsiveness. Uses `group` for parent-child styling.
        <div className={`
            fixed h-screen w-64 bg-white dark:bg-zinc-800 shadow-lg
            flex flex-col p-4 transition-all duration-300 ease-in-out
            transform -translate-x-full md:translate-x-0 z-50
            md:w-64
        `}>
            {/* Sidebar header */}
            <div className="mb-6 pb-4 border-b border-gray-200 dark:border-zinc-700">
                <h2 className="text-2xl font-semibold text-gray-800 dark:text-gray-100">
                    Admin Dashboard
                </h2>
            </div>

            {/* Navigation links */}
            <nav className="flex-1">
                <ul>
                    <li className="mb-2">
                        {/* NavLink for Dashboard */}
                        <NavLink
                            to="/"
                            className={({ isActive }) => `
                                flex items-center p-3 rounded-lg text-gray-700 dark:text-gray-200
                                hover:bg-blue-100 hover:text-blue-700 dark:hover:bg-zinc-700 dark:hover:text-blue-400
                                transition-colors duration-200 ease-in-out
                                ${isActive ? 'bg-blue-600 text-white dark:bg-blue-700 dark:text-white shadow-md' : ''}
                            `}
                        >
                            <LayoutDashboard className="w-5 h-5 mr-3" /> {/* Dashboard icon */}
                            Dashboard
                        </NavLink>
                    </li>
                    <li className="mb-2">
                        {/* NavLink for Drivers */}
                        <NavLink
                            to="/drivers"
                            className={({ isActive }) => `
                                flex items-center p-3 rounded-lg text-gray-700 dark:text-gray-200
                                hover:bg-blue-100 hover:text-blue-700 dark:hover:bg-zinc-700 dark:hover:text-blue-400
                                transition-colors duration-200 ease-in-out
                                ${isActive ? 'bg-blue-600 text-white dark:bg-blue-700 dark:text-white shadow-md' : ''}
                            `}
                        >
                            <Users className="w-5 h-5 mr-3" /> {/* Drivers icon */}
                            Drivers
                        </NavLink>
                    </li>
                    <li className="mb-2">
                        {/* NavLink for Live Map */}
                        <NavLink
                            to="/map"
                            className={({ isActive }) => `
                                flex items-center p-3 rounded-lg text-gray-700 dark:text-gray-200
                                hover:bg-blue-100 hover:text-blue-700 dark:hover:bg-zinc-700 dark:hover:text-blue-400
                                transition-colors duration-200 ease-in-out
                                ${isActive ? 'bg-blue-600 text-white dark:bg-blue-700 dark:text-white shadow-md' : ''}
                            `}
                        >
                            <MapPin className="w-5 h-5 mr-3" /> {/* Map icon */}
                            Live Map
                        </NavLink>
                    </li>
                </ul>
            </nav>
        </div>
    );
};

export default Sidebar;
