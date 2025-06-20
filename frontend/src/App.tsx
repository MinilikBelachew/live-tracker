import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider } from './components/ThemeContext';
import Sidebar from './components/Layout/Sidebar';
import TopNav from './components/Layout/TopNav';
import DriverForm from './components/DriverForm';
import DriverList from './components/DriverList';
import MapView from './components/MapView';
import Dashboard from './components/Dashboard';
// import './styles/main.css'; // No longer needed as styling is handled by Tailwind

function App() {
    // State to trigger refresh for DriverList component
    const [refresh, setRefresh] = useState(false);
    // State to control sidebar open/collapsed state for responsiveness
    const [sidebarOpen, setSidebarOpen] = useState(true);

    // Function to handle driver added event, toggles refresh state
    function handleDriverAdded() {
        setRefresh(r => !r);
    }

    // Function to toggle sidebar visibility
    const toggleSidebar = () => {
        setSidebarOpen(!sidebarOpen);
    };

    return (
        <Router>
            <ThemeProvider>
                {/* Main application container with flex layout and min-height for full viewport */}
                <div className="flex min-h-screen bg-gray-100 dark:bg-zinc-900 transition-colors duration-300">
                    {/* Sidebar component */}
                    <Sidebar />

                    {/* Overlay for sidebar on small screens when open */}
                    {sidebarOpen && (
                        <div
                            className="fixed inset-0 bg-black bg-opacity-50 z-40 md:hidden"
                            onClick={toggleSidebar}
                        ></div>
                    )}

                    {/* Main content area.
                        Adjusts left margin based on sidebar state (open/collapsed on desktop, full width on mobile).
                        Also handles top padding for TopNav. */}
                    <div className={`
                        flex-1 flex flex-col
                        ${sidebarOpen ? 'ml-64' : 'ml-0'}
                        md:ml-64
                        transition-all duration-300 ease-in-out
                    `}>
                        {/* Top Navigation component */}
                        <TopNav toggleSidebar={toggleSidebar} />

                        {/* Content wrapper with padding and top margin to account for fixed TopNav */}
                        <div className="flex-1 p-6 pt-20 md:pt-24 overflow-y-auto">
                            <Routes>
                                {/* Dashboard Route: Displays DriverForm and DriverList */}
                                <Route path="/" element={<Dashboard />} />
                                {/* Drivers Route: Also displays DriverForm and DriverList */}
                                <Route path="/drivers" element={
                                    <>
                                        <DriverForm onDriverAdded={handleDriverAdded} />
                                        <DriverList key={refresh.toString()} />
                                    </>
                                } />
                                {/* Live Map Route: Displays MapView */}
                                <Route path="/map" element={<MapView />} />
                            </Routes>
                        </div>
                    </div>
                </div>
            </ThemeProvider>
        </Router>
    );
}

export default App;
