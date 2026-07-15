import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./lib/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // paleta Enterprise (SAP Fiori-ish)
        brand: {
          50: "#eef4ff", 100: "#dce7ff", 200: "#b9ceff", 300: "#8badff",
          400: "#5a86fa", 500: "#3563e9", 600: "#2049c9", 700: "#1a3aa0",
          800: "#1a337f", 900: "#1b2f66",
        },
      },
      fontFamily: {
        sans: ["var(--font-inter)", "ui-sans-serif", "system-ui", "-apple-system", "Segoe UI", "Roboto", "Helvetica", "Arial", "sans-serif"],
      },
    },
  },
  plugins: [],
};
export default config;
