import React, { createContext, useContext, useState, useEffect } from 'react';

// Define the Theme type
type Theme = 'light' | 'dark';

// Define the shape of the ThemeContext
interface ThemeContextType {
    theme: Theme;
    toggleTheme: () => void;
}

// Create the context with a default value
const ThemeContext = createContext<ThemeContextType>({
    theme: 'light',
    toggleTheme: () => {}, // Placeholder function
});

// ThemeProvider component to wrap the application
export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    // State to hold the current theme
    const [theme, setTheme] = useState<Theme>('light');

    // Effect to read theme from localStorage on initial load
    useEffect(() => {
        // Retrieve saved theme or default to 'light'
        const savedTheme = localStorage.getItem('theme') as Theme || 'light';
        setTheme(savedTheme);
        // Apply the theme class to the document HTML element
        if (savedTheme === 'dark') {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
    }, []); // Empty dependency array ensures this runs only once on mount

    // Function to toggle the theme
    const toggleTheme = () => {
        const newTheme = theme === 'light' ? 'dark' : 'light';
        setTheme(newTheme);
        // Save the new theme to localStorage
        localStorage.setItem('theme', newTheme);
        // Add or remove the 'dark' class from the document HTML element
        if (newTheme === 'dark') {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
    };

    // Provide the theme and toggle function to children components
    return (
        <ThemeContext.Provider value={{ theme, toggleTheme }}>
            {children}
        </ThemeContext.Provider>
    );
};

// Custom hook to easily consume the theme context
export const useTheme = () => useContext(ThemeContext);
