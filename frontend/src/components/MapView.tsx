import React, { useState, useEffect, useRef } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import { Icon, type LatLngExpression } from "leaflet";
import "leaflet/dist/leaflet.css";
import { io, Socket } from "socket.io-client";
import { useTheme } from "./ThemeContext";

const driverIcon = new Icon({
  iconUrl: "https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});

interface DriverLocation {
  lat: number;
  lng: number;
  firstName?: string;
  lastName?: string;
}

export default function MapView() {
  const [drivers, setDrivers] = useState<Record<number, DriverLocation>>({});
  const [socket, setSocket] = useState<Socket | null>(null);
  const { theme } = useTheme();
  const markerRefs = useRef<Record<number, any>>({});

  useEffect(() => {
    const s = io(import.meta.env.VITE_SOCKET as string);
    setSocket(s);

    s.on("updateLocation", (data: {
      driverId: number;
      lat: number;
      lng: number;
      firstName?: string;
      lastName?: string;
    }) => {
      setDrivers(prev => {
        const currentDriverLocation = prev[data.driverId];
        const newLocation: LatLngExpression = [data.lat, data.lng];

        if (currentDriverLocation && markerRefs.current[data.driverId]) {
          const marker = markerRefs.current[data.driverId];
          const oldLatLng = marker.getLatLng();
          const newLatLng = newLocation;
          const animationDuration = 500;
          const frames = 30;
          let currentFrame = 0;

          const animate = () => {
            if (!marker || currentFrame >= frames) {
              return;
            }

            const ratio = currentFrame / frames;
            const interpolatedLat = oldLatLng.lat + (newLatLng[0] - oldLatLng.lat) * ratio;
            const interpolatedLng = oldLatLng.lng + (newLatLng[1] - oldLatLng.lng) * ratio;

            marker.setLatLng([interpolatedLat, interpolatedLng]);
            currentFrame++;

            if (currentFrame < frames) {
              requestAnimationFrame(animate);
            } else {
              marker.setLatLng(newLatLng);
            }
          };

          requestAnimationFrame(animate);
        }

        return {
          ...prev,
          [data.driverId]: {
            lat: data.lat,
            lng: data.lng,
            firstName: data.firstName,
            lastName: data.lastName,
          }
        };
      });
    });

    return () => {
      s.off("updateLocation");
      s.disconnect();
    };
  }, []);

  return (
    <div className={`bg-white dark:bg-gray-800 rounded-lg shadow-lg overflow-hidden transition-colors duration-200 ${theme === 'dark' ? 'text-white' : 'text-gray-800'}`}>
      <div className="bg-indigo-600 dark:bg-indigo-700 px-6 py-4">
        <h3 className="text-xl font-semibold text-white flex items-center">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          Live Driver Locations
        </h3>
      </div>
      
      <div className="p-0 h-[500px] w-full">
        <MapContainer
          center={[39.7392, -104.9903]}
          zoom={13}
          style={{ height: "100%", width: "100%" }}
          className="z-0"
        >
          <TileLayer
            url={theme === 'dark' 
              ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
              : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            }
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          />
          {Object.entries(drivers).map(([driverId, location]) => (
            <Marker
              key={driverId}
              position={[location.lat, location.lng]}
              icon={driverIcon}
              ref={el => {
                if (el) {
                  markerRefs.current[parseInt(driverId)] = el;
                } else {
                  delete markerRefs.current[parseInt(driverId)];
                }
              }}
            >
              <Popup className="leaflet-popup-custom">
                <div className="py-1">
                  <h4 className="font-bold text-indigo-700">Driver {driverId}</h4>
                  {location.firstName && location.lastName && (
                    <p className="text-gray-800">{location.firstName} {location.lastName}</p>
                  )}
                  <div className="mt-2 grid grid-cols-2 gap-2 text-sm text-gray-600">
                    <div>Lat: {location.lat.toFixed(4)}</div>
                    <div>Lng: {location.lng.toFixed(4)}</div>
                  </div>
                </div>
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </div>
      <div className="bg-gray-100 dark:bg-gray-900 px-4 py-3 text-sm text-gray-600 dark:text-gray-400">
        <div className="flex items-center">
          <span className="mr-2 h-3 w-3 rounded-full bg-green-500 inline-block"></span>
          <span className="mr-4">Active driver</span>
          <span className="text-xs">Total drivers: {Object.keys(drivers).length}</span>
        </div>
      </div>
    </div>
  );
}