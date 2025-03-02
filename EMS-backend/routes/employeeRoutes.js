const express = require("express");
const { authMiddleware, adminAuthMiddleware } = require("../middleware/authMiddleware");
const {
  registerEmployee,
  loginEmployee,
  getEmployeeProfile,
  getAllEmployees,
  getEmployeeById,
  adminUpdateEmployee,
  adminDeleteEmployee,
  adminResetEmployeePassword,
} = require("../controllers/employeeController");

const router = express.Router();

router.post("/register", registerEmployee);
router.post("/login", loginEmployee);
router.get("/profile", authMiddleware, getEmployeeProfile);
router.get("/", adminAuthMiddleware, getAllEmployees);
router.get("/:employeeId", adminAuthMiddleware, getEmployeeById);
router.put("/update/:employeeId", adminAuthMiddleware, adminUpdateEmployee);
router.delete("/delete/:employeeId", adminAuthMiddleware, adminDeleteEmployee);
router.post("/reset-password/:employeeId", adminAuthMiddleware, adminResetEmployeePassword);

module.exports = router;
