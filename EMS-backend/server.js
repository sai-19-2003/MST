require("dotenv").config();
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const connectDB = require("./config/db");

// Import Routes
const authRoutes = require("./routes/authRoutes");
const employeeRoutes = require("./routes/employeeRoutes");
const adminRoutes = require("./routes/adminRoutes");
const attendanceRoutes = require("./routes/attendanceRoutes");

// Initialize Express App
const app = express();

// ✅ **Middleware Configuration**
app.use(cors({ origin: "*" })); // Enable CORS globally (Consider restricting in production)
app.use(bodyParser.json()); // Parse JSON request body
app.use(express.urlencoded({ extended: true })); // Support URL-encoded requests

// ✅ **Connect to MongoDB**
connectDB().then(() => console.log("✅ MongoDB Connected Successfully")).catch(err => console.error("❌ MongoDB Connection Error:", err));

// ✅ **API Routes**
app.use("/api/auth", authRoutes);
app.use("/api/employees", employeeRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/attendance", attendanceRoutes);

// ✅ **Health Check Route**
app.get("/", (req, res) => {
  res.status(200).json({ success: true, message: "🚀 Employee Management System API is Running!" });
});

// ✅ **Global Error Handling Middleware**
app.use((err, req, res, next) => {
  console.error("❌ Server Error:", err);
  res.status(500).json({ success: false, message: "Internal Server Error", error: err.message });
});

// ✅ **Start Server**
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
