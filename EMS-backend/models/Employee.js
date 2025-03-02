const mongoose = require("mongoose");

const EmployeeSchema = new mongoose.Schema(
  {
    employeeId: {
      type: String,
      unique: true,
    },
    name: {
      type: String,
      required: true,
    },
    phone: {
      type: String,
      unique: true,
      required: true,
    },
    password: {
      type: String,
      required: true,
    },
  },
  { timestamps: true }
);

// ✅ Generate Employee ID (MST1, MST2, MST3)
EmployeeSchema.pre("save", async function (next) {
  if (!this.employeeId) {
    const lastEmployee = await mongoose.model("Employee").findOne({}, {}, { sort: { createdAt: -1 } });
    const lastId = lastEmployee ? parseInt(lastEmployee.employeeId.replace("MST", "")) : 0;
    this.employeeId = `MST${lastId + 1}`;
  }
  next();
});

module.exports = mongoose.model("Employee", EmployeeSchema);
