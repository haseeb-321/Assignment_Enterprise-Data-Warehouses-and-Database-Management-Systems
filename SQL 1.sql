CREATE DATABASE HealthcareManagementSystem;
USE HealthcareManagementSystem;

-- 1. Core Entities
CREATE TABLE Patients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    NationalID VARCHAR(20) UNIQUE NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    BloodType ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    ContactNumber VARCHAR(15),
    EmergencyContact VARCHAR(15),
    Address TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE MedicalStaff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    LicenseNumber VARCHAR(20) UNIQUE NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Specialization VARCHAR(100) NOT NULL,
    Qualification ENUM('MBBS', 'MD', 'MS', 'PhD', 'BDS', 'DPharm', 'MNurse') NOT NULL,
    Department ENUM('Cardiology', 'Neurology', 'Pediatrics', 'Surgery', 'Emergency', 'Radiology', 'Pharmacy', 'Laboratory') NOT NULL,
    YearsOfExperience INT,
    ContactNumber VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    HireDate DATE NOT NULL,
    Status ENUM('Active', 'OnLeave', 'Inactive') DEFAULT 'Active'
);

CREATE TABLE Departments (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName VARCHAR(100) UNIQUE NOT NULL,
    HeadOfDepartment INT,
    Location VARCHAR(100),
    ContactExtension VARCHAR(10),
    Budget DECIMAL(15,2),
    FOREIGN KEY (HeadOfDepartment) REFERENCES MedicalStaff(StaffID)
);

CREATE TABLE MedicalProcedures (
    ProcedureID INT AUTO_INCREMENT PRIMARY KEY,
    ProcedureCode VARCHAR(20) UNIQUE NOT NULL,
    ProcedureName VARCHAR(200) NOT NULL,
    Description TEXT,
    DurationMinutes INT,
    StandardCost DECIMAL(10,2) NOT NULL,
    Category ENUM('Diagnostic', 'Surgical', 'Therapeutic', 'Preventive') NOT NULL,
    RiskLevel ENUM('Low', 'Medium', 'High') DEFAULT 'Medium'
);

CREATE TABLE Medications (
    MedicationID INT AUTO_INCREMENT PRIMARY KEY,
    MedicationCode VARCHAR(20) UNIQUE NOT NULL,
    GenericName VARCHAR(100) NOT NULL,
    BrandName VARCHAR(100),
    DosageForm ENUM('Tablet', 'Capsule', 'Injection', 'Syrup', 'Ointment', 'Inhaler') NOT NULL,
    Strength VARCHAR(50),
    Manufacturer VARCHAR(100),
    UnitPrice DECIMAL(8,2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    ReorderLevel INT DEFAULT 10
);

CREATE TABLE LaboratoryTests (
    TestID INT AUTO_INCREMENT PRIMARY KEY,
    TestCode VARCHAR(20) UNIQUE NOT NULL,
    TestName VARCHAR(100) NOT NULL,
    Description TEXT,
    NormalRange TEXT,
    TestDuration INT, -- in minutes
    Cost DECIMAL(8,2) NOT NULL,
    SampleType ENUM('Blood', 'Urine', 'Tissue', 'Saliva', 'Other') NOT NULL
);

CREATE TABLE InsuranceCompanies (
    CompanyID INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(100) UNIQUE NOT NULL,
    ContactPerson VARCHAR(100),
    PhoneNumber VARCHAR(15),
    Email VARCHAR(100),
    Address TEXT,
    CoverageLimit DECIMAL(12,2),
    ClaimProcessingDays INT DEFAULT 14
);

CREATE TABLE MedicalEquipment (
    EquipmentID INT AUTO_INCREMENT PRIMARY KEY,
    EquipmentCode VARCHAR(20) UNIQUE NOT NULL,
    EquipmentName VARCHAR(100) NOT NULL,
    Manufacturer VARCHAR(100),
    Model VARCHAR(50),
    PurchaseDate DATE,
    LastMaintenance DATE,
    NextMaintenance DATE,
    Status ENUM('Operational', 'Maintenance', 'OutOfService') DEFAULT 'Operational',
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Wards (
    WardID INT AUTO_INCREMENT PRIMARY KEY,
    WardNumber VARCHAR(10) UNIQUE NOT NULL,
    WardType ENUM('General', 'ICU', 'CCU', 'Pediatric', 'Maternity', 'Surgical') NOT NULL,
    Capacity INT NOT NULL,
    CurrentOccupancy INT DEFAULT 0,
    ChargePerDay DECIMAL(8,2) NOT NULL,
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Appointments (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME NOT NULL,
    Status ENUM('Scheduled', 'Completed', 'Cancelled', 'NoShow') DEFAULT 'Scheduled',
    ReasonForVisit TEXT,
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES MedicalStaff(StaffID)
);

-- 2. Many-to-Many Relationship Tables (Junction Tables)

-- Junction Table 1: StaffDepartmentAssignments (MedicalStaff - Departments)
CREATE TABLE StaffDepartmentAssignments (
    AssignmentID INT AUTO_INCREMENT PRIMARY KEY,
    StaffID INT NOT NULL,
    DepartmentID INT NOT NULL,
    AssignmentType ENUM('Primary', 'Secondary', 'Consulting') DEFAULT 'Primary',
    StartDate DATE NOT NULL,
    EndDate DATE,
    FOREIGN KEY (StaffID) REFERENCES MedicalStaff(StaffID),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    UNIQUE KEY unique_staff_department (StaffID, DepartmentID, AssignmentType)
);

-- Junction Table 2: PatientAllergies (Patients - Medications)
CREATE TABLE PatientAllergies (
    AllergyID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    MedicationID INT NOT NULL,
    AllergyType ENUM('Drug', 'Food', 'Environmental') DEFAULT 'Drug',
    Severity ENUM('Mild', 'Moderate', 'Severe') NOT NULL,
    FirstObserved DATE,
    Notes TEXT,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (MedicationID) REFERENCES Medications(MedicationID),
    UNIQUE KEY unique_patient_allergy (PatientID, MedicationID)
);

-- Junction Table 3: PatientInsurance (Patients - InsuranceCompanies)
CREATE TABLE PatientInsurance (
    InsuranceID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    CompanyID INT NOT NULL,
    PolicyNumber VARCHAR(50) NOT NULL,
    CoverageStart DATE NOT NULL,
    CoverageEnd DATE,
    PremiumAmount DECIMAL(10,2),
    DeductibleAmount DECIMAL(8,2),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (CompanyID) REFERENCES InsuranceCompanies(CompanyID),
    UNIQUE KEY unique_patient_policy (PatientID, PolicyNumber)
);

-- Junction Table 4: TreatmentPlans (Patients - MedicalProcedures - MedicalStaff)
CREATE TABLE TreatmentPlans (
    PlanID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    ProcedureID INT NOT NULL,
    PrescribingDoctorID INT NOT NULL,
    PlanDate DATE NOT NULL,
    ScheduledDate DATE,
    Status ENUM('Planned', 'InProgress', 'Completed', 'Cancelled') DEFAULT 'Planned',
    Notes TEXT,
    EstimatedCost DECIMAL(10,2),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (ProcedureID) REFERENCES MedicalProcedures(ProcedureID),
    FOREIGN KEY (PrescribingDoctorID) REFERENCES MedicalStaff(StaffID)
);

-- Junction Table 5: Prescriptions (Patients - Medications - MedicalStaff)
CREATE TABLE Prescriptions (
    PrescriptionID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    MedicationID INT NOT NULL,
    PrescribingDoctorID INT NOT NULL,
    PrescriptionDate DATE NOT NULL,
    Dosage VARCHAR(100) NOT NULL,
    Frequency VARCHAR(50) NOT NULL,
    DurationDays INT NOT NULL,
    Quantity INT NOT NULL,
    RefillsAllowed INT DEFAULT 0,
    Status ENUM('Active', 'Completed', 'Cancelled') DEFAULT 'Active',
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (MedicationID) REFERENCES Medications(MedicationID),
    FOREIGN KEY (PrescribingDoctorID) REFERENCES MedicalStaff(StaffID)
);

-- 3. Transaction Tables
CREATE TABLE MedicalRecords (
    RecordID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    VisitDate DATETIME NOT NULL,
    Diagnosis TEXT NOT NULL,
    Symptoms TEXT,
    TreatmentProvided TEXT,
    FollowUpRequired BOOLEAN DEFAULT FALSE,
    FollowUpDate DATE,
    Height DECIMAL(4,1), -- in cm
    Weight DECIMAL(4,1), -- in kg
    BloodPressure VARCHAR(10),
    HeartRate INT,
    Temperature DECIMAL(3,1),
    Notes TEXT,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES MedicalStaff(StaffID)
);

CREATE TABLE LaboratoryResults (
    ResultID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    TestID INT NOT NULL,
    DoctorID INT NOT NULL,
    TestDate DATETIME NOT NULL,
    ResultValue VARCHAR(100),
    ResultUnit VARCHAR(20),
    NormalRange VARCHAR(50),
    Interpretation ENUM('Normal', 'Abnormal', 'Critical') DEFAULT 'Normal',
    Findings TEXT,
    ReviewedBy INT,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (TestID) REFERENCES LaboratoryTests(TestID),
    FOREIGN KEY (DoctorID) REFERENCES MedicalStaff(StaffID),
    FOREIGN KEY (ReviewedBy) REFERENCES MedicalStaff(StaffID)
);

CREATE TABLE Billing (
    BillID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    AppointmentID INT,
    BillDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    InsuranceCoverage DECIMAL(10,2) DEFAULT 0,
    PatientPayment DECIMAL(10,2) DEFAULT 0,
    PaymentStatus ENUM('Pending', 'PartiallyPaid', 'Paid', 'InsuranceClaim') DEFAULT 'Pending',
    DueDate DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
);

CREATE TABLE Admissions (
    AdmissionID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    WardID INT NOT NULL,
    AdmittingDoctorID INT NOT NULL,
    AdmissionDate DATETIME NOT NULL,
    DischargeDate DATETIME,
    ReasonForAdmission TEXT NOT NULL,
    Diagnosis TEXT,
    Status ENUM('Admitted', 'Discharged', 'Transferred') DEFAULT 'Admitted',
    BedNumber VARCHAR(10),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (WardID) REFERENCES Wards(WardID),
    FOREIGN KEY (AdmittingDoctorID) REFERENCES MedicalStaff(StaffID)
);





-- Show all tables
SHOW TABLES;



-- Insert sample data for all tables

-- Patients (10 rows)
INSERT INTO Patients (NationalID, FirstName, LastName, DateOfBirth, Gender, BloodType, ContactNumber, EmergencyContact, Address) VALUES
('12345-6789012-3', 'Ahmed', 'Khan', '1985-03-15', 'Male', 'B+', '0300-1234567', '0300-7654321', 'House 123, Street 45, Lahore'),
('23456-7890123-4', 'Fatima', 'Ali', '1990-07-22', 'Female', 'O+', '0312-3456789', '0313-4567890', 'Apartment 5, Block C, Karachi'),
('34567-8901234-5', 'Usman', 'Malik', '1978-11-30', 'Male', 'A-', '0333-9876543', '0334-8765432', 'Village Kot, District Multan'),
('45678-9012345-6', 'Ayesha', 'Raza', '1995-12-10', 'Female', 'AB+', '0301-1122334', '0302-2233445', 'Street 7, Phase 2, Islamabad'),
('56789-0123456-7', 'Bilal', 'Hussain', '1982-06-25', 'Male', 'O-', '0331-4455667', '0332-5566778', 'Sector F-8/4, Islamabad'),
('67890-1234567-8', 'Sana', 'Jamal', '1975-09-18', 'Female', 'B-', '0314-7788990', '0315-8899001', 'Defence Road, Lahore'),
('78901-2345678-9', 'Kamran', 'Shah', '1988-04-05', 'Male', 'A+', '0304-9988776', '0305-8877665', 'Gulberg III, Lahore'),
('89012-3456789-0', 'Nadia', 'Akhtar', '1992-08-14', 'Female', 'O+', '0321-5544332', '0322-6655443', 'Clifton Block 9, Karachi'),
('90123-4567890-1', 'Tariq', 'Mehmood', '1965-01-30', 'Male', 'AB-', '0336-7766554', '0337-8877665', 'University Road, Peshawar'),
('01234-5678901-2', 'Hina', 'Siddiqui', '1987-11-22', 'Female', 'A+', '0307-4433221', '0308-5544332', 'Cantt Area, Rawalpindi');

-- MedicalStaff (10 rows)
INSERT INTO MedicalStaff (LicenseNumber, FirstName, LastName, Specialization, Qualification, Department, YearsOfExperience, ContactNumber, Email, HireDate) VALUES
('PMDC-12345', 'Sarah', 'Johnson', 'Cardiologist', 'MD', 'Cardiology', 15, '0301-2345678', 'sarah.johnson@hospital.com', '2015-06-01'),
('PMDC-23456', 'Ali', 'Raza', 'Neurosurgeon', 'MS', 'Neurology', 20, '0302-3456789', 'ali.raza@hospital.com', '2010-03-15'),
('PMDC-34567', 'Ayesha', 'Siddiqui', 'Pediatrician', 'MBBS', 'Pediatrics', 8, '0303-4567890', 'ayesha.siddiqui@hospital.com', '2018-09-01'),
('PMDC-45678', 'David', 'Smith', 'Orthopedic Surgeon', 'MS', 'Surgery', 12, '0304-5678901', 'david.smith@hospital.com', '2016-11-20'),
('PMDC-56789', 'Maria', 'Garcia', 'Gynecologist', 'MD', 'Emergency', 18, '0305-6789012', 'maria.garcia@hospital.com', '2012-08-10'),
('PMDC-67890', 'Robert', 'Brown', 'Radiologist', 'PhD', 'Radiology', 10, '0306-7890123', 'robert.brown@hospital.com', '2019-04-15'),
('PMDC-78901', 'Chen', 'Wei', 'Anesthesiologist', 'MD', 'Surgery', 14, '0307-8901234', 'chen.wei@hospital.com', '2014-07-22'),
('PMDC-89012', 'Emma', 'Wilson', 'Dermatologist', 'MBBS', 'Emergency', 6, '0308-9012345', 'emma.wilson@hospital.com', '2020-02-28'),
('PMDC-90123', 'James', 'Taylor', 'Psychiatrist', 'MD', 'Emergency', 16, '0309-0123456', 'james.taylor@hospital.com', '2013-12-01'),
('PMDC-01234', 'Lisa', 'Anderson', 'Oncologist', 'PhD', 'Radiology', 22, '0310-1234567', 'lisa.anderson@hospital.com', '2008-05-10');

-- Departments (8 rows)
INSERT INTO Departments (DepartmentName, HeadOfDepartment, Location, ContactExtension, Budget) VALUES
('Cardiology', 1, 'Building A, Floor 3', '2345', 5000000.00),
('Neurology', 2, 'Building B, Floor 2', '3456', 4500000.00),
('Pediatrics', 3, 'Building C, Floor 1', '4567', 3000000.00),
('Surgery', 4, 'Building D, Floor 4', '5678', 6000000.00),
('Emergency', 5, 'Building E, Ground Floor', '6789', 3500000.00),
('Radiology', 6, 'Building F, Floor 1', '7890', 4000000.00),
('Pharmacy', NULL, 'Building G, Ground Floor', '8901', 1500000.00),
('Laboratory', NULL, 'Building H, Floor 2', '9012', 2000000.00);

-- MedicalProcedures (10 rows)
INSERT INTO MedicalProcedures (ProcedureCode, ProcedureName, Description, DurationMinutes, StandardCost, Category, RiskLevel) VALUES
('PROC-001', 'Cardiac Catheterization', 'Examination of heart arteries', 120, 50000.00, 'Diagnostic', 'High'),
('PROC-002', 'Appendectomy', 'Surgical removal of appendix', 90, 35000.00, 'Surgical', 'Medium'),
('PROC-003', 'MRI Scan', 'Magnetic Resonance Imaging', 60, 15000.00, 'Diagnostic', 'Low'),
('PROC-004', 'Chemotherapy Session', 'Cancer treatment session', 180, 25000.00, 'Therapeutic', 'High'),
('PROC-005', 'Vaccination', 'Routine immunization', 15, 2000.00, 'Preventive', 'Low'),
('PROC-006', 'Knee Replacement', 'Total knee arthroplasty', 240, 120000.00, 'Surgical', 'High'),
('PROC-007', 'Endoscopy', 'GI tract examination', 45, 18000.00, 'Diagnostic', 'Medium'),
('PROC-008', 'Dialysis', 'Kidney function treatment', 240, 8000.00, 'Therapeutic', 'Medium'),
('PROC-009', 'Cataract Surgery', 'Eye lens replacement', 60, 40000.00, 'Surgical', 'Medium'),
('PROC-010', 'Physical Therapy', 'Rehabilitation session', 60, 3000.00, 'Therapeutic', 'Low');

-- Medications (10 rows)
INSERT INTO Medications (MedicationCode, GenericName, BrandName, DosageForm, Strength, Manufacturer, UnitPrice, StockQuantity, ReorderLevel) VALUES
('MED-001', 'Paracetamol', 'Panadol', 'Tablet', '500mg', 'GSK', 5.00, 1000, 100),
('MED-002', 'Amoxicillin', 'Amoxil', 'Capsule', '250mg', 'Pfizer', 15.00, 500, 50),
('MED-003', 'Insulin', 'Humulin', 'Injection', '100IU/ml', 'Eli Lilly', 800.00, 100, 20),
('MED-004', 'Atorvastatin', 'Lipitor', 'Tablet', '20mg', 'Pfizer', 25.00, 300, 30),
('MED-005', 'Metformin', 'Glucophage', 'Tablet', '500mg', 'Merck', 12.00, 400, 40),
('MED-006', 'Salbutamol', 'Ventolin', 'Inhaler', '100mcg', 'GSK', 150.00, 200, 25),
('MED-007', 'Omeprazole', 'Losec', 'Capsule', '20mg', 'AstraZeneca', 18.00, 350, 35),
('MED-008', 'Ceftriaxone', 'Rocephin', 'Injection', '1g', 'Roche', 120.00, 150, 15),
('MED-009', 'Diazepam', 'Valium', 'Tablet', '5mg', 'Roche', 8.00, 600, 60),
('MED-010', 'Ibuprofen', 'Brufen', 'Tablet', '400mg', 'Abbott', 7.00, 800, 80);

-- LaboratoryTests (10 rows)
INSERT INTO LaboratoryTests (TestCode, TestName, Description, NormalRange, TestDuration, Cost, SampleType) VALUES
('LAB-001', 'Complete Blood Count', 'Blood cell analysis', 'WBC: 4.5-11.0', 30, 800.00, 'Blood'),
('LAB-002', 'Lipid Profile', 'Cholesterol levels', 'LDL: <100 mg/dL', 45, 1200.00, 'Blood'),
('LAB-003', 'Liver Function Test', 'Liver enzyme analysis', 'ALT: 7-55 U/L', 60, 1500.00, 'Blood'),
('LAB-004', 'Urine Analysis', 'Urine chemical analysis', 'pH: 4.5-8.0', 20, 500.00, 'Urine'),
('LAB-005', 'Thyroid Profile', 'Thyroid hormone levels', 'TSH: 0.4-4.0 mIU/L', 90, 2000.00, 'Blood'),
('LAB-006', 'Blood Culture', 'Bacterial infection test', 'No growth', 72, 2500.00, 'Blood'),
('LAB-007', 'Glucose Tolerance', 'Diabetes screening', 'Fasting: <100 mg/dL', 120, 1800.00, 'Blood'),
('LAB-008', 'HIV Test', 'HIV antibody detection', 'Negative', 60, 1500.00, 'Blood'),
('LAB-009', 'Pregnancy Test', 'hCG detection', 'Negative/<5 mIU/mL', 15, 300.00, 'Urine'),
('LAB-010', 'COVID-19 PCR', 'SARS-CoV-2 detection', 'Negative', 24, 2000.00, 'Saliva');

-- InsuranceCompanies (8 rows)
INSERT INTO InsuranceCompanies (CompanyName, ContactPerson, PhoneNumber, Email, Address, CoverageLimit, ClaimProcessingDays) VALUES
('State Life Insurance', 'Mr. Asif Ali', '021-34567890', 'info@statelife.com', 'I.I. Chundrigar Road, Karachi', 1000000.00, 10),
('Adamjee Insurance', 'Ms. Sara Khan', '042-37894567', 'claims@adamjee.com', 'The Mall, Lahore', 1500000.00, 7),
('EFU Health Insurance', 'Mr. Tariq Mahmood', '051-23456789', 'support@efu.com', 'Blue Area, Islamabad', 2000000.00, 5),
('Jubilee Life Insurance', 'Ms. Amina Hassan', '022-38765432', 'service@jubilee.com', 'Sharea Faisal, Karachi', 1200000.00, 8),
('ICAP Insurance', 'Mr. Bilal Ahmed', '061-45873219', 'info@icap.com', 'Cantt, Multan', 800000.00, 12),
('TPL Insurance', 'Ms. Nadia Shah', '081-28765431', 'help@tpl.com', 'University Road, Peshawar', 900000.00, 9),
('IGI Insurance', 'Mr. Kamran Butt', '052-36789451', 'contact@igi.com', 'Saddar, Rawalpindi', 1100000.00, 6),
('AsiaCare Insurance', 'Ms. Farah Malik', '071-58346721', 'support@asiacare.com', 'Jinnah Road, Quetta', 700000.00, 14);

-- MedicalEquipment (10 rows)
INSERT INTO MedicalEquipment (EquipmentCode, EquipmentName, Manufacturer, Model, PurchaseDate, LastMaintenance, NextMaintenance, Status, DepartmentID) VALUES
('EQ-001', 'MRI Machine', 'Siemens', 'Magnetom Aera', '2022-01-15', '2024-01-10', '2025-01-10', 'Operational', 6),
('EQ-002', 'CT Scanner', 'GE Healthcare', 'Revolution EVO', '2021-06-20', '2024-02-15', '2025-02-15', 'Operational', 6),
('EQ-003', 'Ventilator', 'Philips', 'Trilogy 202', '2023-03-10', '2024-03-01', '2025-03-01', 'Operational', 5),
('EQ-004', 'Defibrillator', 'Zoll', 'X Series', '2022-11-05', '2024-01-20', '2025-01-20', 'Maintenance', 5),
('EQ-005', 'Ultrasound', 'Canon', 'Aplio i800', '2023-08-12', '2024-04-05', '2025-04-05', 'Operational', 6),
('EQ-006', 'Anesthesia Machine', 'Drager', 'Perseus A500', '2021-12-18', '2024-02-28', '2025-02-28', 'Operational', 4),
('EQ-007', 'Patient Monitor', 'Mindray', 'BeneVision N22', '2023-05-22', '2024-03-15', '2025-03-15', 'Operational', 1),
('EQ-008', 'Dialysis Machine', 'Fresenius', '4008S', '2022-09-30', '2024-01-25', '2025-01-25', 'OutOfService', 5),
('EQ-009', 'ECG Machine', 'Schiller', 'AT-102', '2023-02-14', '2024-04-10', '2025-04-10', 'Operational', 1),
('EQ-010', 'Infusion Pump', 'Baxter', 'Sigma Spectrum', '2022-07-08', '2024-03-20', '2025-03-20', 'Operational', 5);

-- Wards (8 rows)
INSERT INTO Wards (WardNumber, WardType, Capacity, CurrentOccupancy, ChargePerDay, DepartmentID) VALUES
('W-101', 'ICU', 10, 8, 15000.00, 1),
('W-102', 'General', 20, 15, 5000.00, 1),
('W-201', 'CCU', 8, 6, 12000.00, 2),
('W-202', 'General', 25, 18, 4500.00, 2),
('W-301', 'Pediatric', 15, 12, 6000.00, 3),
('W-401', 'Surgical', 12, 9, 8000.00, 4),
('W-501', 'Maternity', 18, 14, 7000.00, 5),
('W-601', 'General', 30, 22, 4000.00, 6);

-- Appointments (10 rows)
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status, ReasonForVisit) VALUES
(1, 1, '2024-04-01 09:00:00', 'Completed', 'Routine heart checkup'),
(2, 2, '2024-04-01 10:30:00', 'Completed', 'Headache and dizziness'),
(3, 3, '2024-04-01 11:15:00', 'Completed', 'Child vaccination'),
(4, 1, '2024-04-02 14:00:00', 'Scheduled', 'Chest pain evaluation'),
(5, 4, '2024-04-02 15:30:00', 'Scheduled', 'Knee pain consultation'),
(6, 5, '2024-04-03 10:00:00', 'Scheduled', 'Annual gynecological exam'),
(7, 6, '2024-04-03 11:45:00', 'Cancelled', 'MRI scan follow-up'),
(8, 7, '2024-04-04 09:30:00', 'Scheduled', 'Pre-surgery anesthesia consult'),
(9, 8, '2024-04-04 13:15:00', 'Scheduled', 'Skin allergy treatment'),
(10, 9, '2024-04-05 16:00:00', 'Scheduled', 'Psychological evaluation');

-- Many-to-Many Relationship Tables

-- StaffDepartmentAssignments (10 rows)
INSERT INTO StaffDepartmentAssignments (StaffID, DepartmentID, AssignmentType, StartDate) VALUES
(1, 1, 'Primary', '2023-01-01'),
(2, 2, 'Primary', '2023-01-01'),
(3, 3, 'Primary', '2023-01-01'),
(4, 4, 'Primary', '2023-01-01'),
(5, 5, 'Primary', '2023-01-01'),
(6, 6, 'Primary', '2023-01-01'),
(7, 4, 'Primary', '2023-01-01'),
(8, 5, 'Primary', '2023-01-01'),
(9, 5, 'Primary', '2023-01-01'),
(10, 6, 'Primary', '2023-01-01'),
(1, 2, 'Consulting', '2023-02-01'),
(2, 1, 'Consulting', '2023-03-15');

-- PatientAllergies (10 rows)
INSERT INTO PatientAllergies (PatientID, MedicationID, AllergyType, Severity, FirstObserved, Notes) VALUES
(1, 2, 'Drug', 'Moderate', '2020-05-15', 'Rash and itching'),
(2, 9, 'Drug', 'Severe', '2019-08-22', 'Anaphylactic reaction'),
(3, 5, 'Drug', 'Mild', '2021-11-30', 'Mild stomach upset'),
(4, 2, 'Drug', 'Moderate', '2022-03-10', 'Hives and swelling'),
(5, 8, 'Drug', 'Severe', '2018-07-18', 'Breathing difficulty'),
(6, 1, 'Drug', 'Mild', '2023-01-05', 'Mild skin reaction'),
(7, 3, 'Drug', 'Moderate', '2020-09-14', 'Nausea and dizziness'),
(8, 7, 'Drug', 'Mild', '2022-12-20', 'Mild headache'),
(9, 4, 'Drug', 'Severe', '2017-04-25', 'Severe allergic reaction'),
(10, 6, 'Drug', 'Moderate', '2021-06-08', 'Chest tightness');

-- PatientInsurance (10 rows)
INSERT INTO PatientInsurance (PatientID, CompanyID, PolicyNumber, CoverageStart, CoverageEnd, PremiumAmount, DeductibleAmount) VALUES
(1, 1, 'SLI-2024001', '2024-01-01', '2024-12-31', 12000.00, 5000.00),
(2, 2, 'ADJ-2024002', '2024-02-01', '2025-01-31', 15000.00, 3000.00),
(3, 3, 'EFU-2024003', '2024-01-15', '2024-12-14', 18000.00, 2000.00),
(4, 4, 'JBL-2024004', '2024-03-01', '2025-02-28', 14000.00, 4000.00),
(5, 5, 'ICP-2024005', '2024-01-01', '2024-12-31', 10000.00, 6000.00),
(6, 6, 'TPL-2024006', '2024-02-15', '2025-02-14', 13000.00, 3500.00),
(7, 7, 'IGI-2024007', '2024-01-20', '2024-12-19', 16000.00, 2500.00),
(8, 8, 'ASC-2024008', '2024-03-10', '2025-03-09', 11000.00, 4500.00),
(9, 1, 'SLI-2024009', '2024-01-01', '2024-12-31', 17000.00, 1500.00),
(10, 2, 'ADJ-2024010', '2024-02-01', '2025-01-31', 12500.00, 3200.00);


-- First check the current column definition
SHOW COLUMNS FROM TreatmentPlans LIKE 'Status';

-- Then alter the column to allow longer values
ALTER TABLE TreatmentPlans MODIFY Status VARCHAR(20);

-- TreatmentPlans (10 rows)
INSERT INTO TreatmentPlans (PatientID, ProcedureID, PrescribingDoctorID, PlanDate, ScheduledDate, Status, Notes, EstimatedCost) VALUES
(1, 1, 1, '2024-03-15', '2024-04-10', 'Planned', 'Cardiac evaluation needed', 50000.00),
(2, 3, 2, '2024-03-20', '2024-04-05', 'Progress', 'Neurological assessment', 15000.00),
(3, 5, 3, '2024-03-25', '2024-04-02', 'Done', 'Routine vaccination', 2000.00),
(4, 2, 4, '2024-04-01', '2024-04-15', 'Planned', 'Appendectomy scheduled', 35000.00),
(5, 6, 4, '2024-03-28', '2024-05-10', 'Planned', 'Knee replacement surgery', 120000.00),
(6, 4, 10, '2024-04-02', '2024-04-20', 'Progress', 'Chemotherapy cycle 1', 25000.00),
(7, 7, 1, '2024-03-30', '2024-04-12', 'Planned', 'GI endoscopy required', 18000.00),
(8, 9, 7, '2024-04-03', '2024-04-25', 'Plan', 'Cataract surgery', 40000.00),  -- Changed from 'Scheduled'
(9, 8, 5, '2024-04-01', '2024-04-08', 'Done', 'Regular dialysis', 8000.00),
(10, 10, 4, '2024-03-27', '2024-04-18', 'Progress', 'Post-surgery therapy', 3000.00);
-- Prescriptions (10 rows)
INSERT INTO Prescriptions (PatientID, MedicationID, PrescribingDoctorID, PrescriptionDate, Dosage, Frequency, DurationDays, Quantity, RefillsAllowed, Status) VALUES
(1, 4, 1, '2024-04-01', '1 tablet', 'Once daily', 30, 30, 2, 'Active'),
(2, 1, 2, '2024-04-01', '500mg', 'Every 6 hours', 7, 28, 0, 'Completed'),
(3, 5, 3, '2024-04-01', '500mg', 'Twice daily', 14, 28, 1, 'Active'),
(4, 7, 1, '2024-04-02', '20mg', 'Once daily', 30, 30, 3, 'Active'),
(5, 9, 4, '2024-04-02', '5mg', 'As needed', 15, 15, 0, 'Active'),
(6, 3, 5, '2024-04-03', '10 units', 'Before meals', 90, 1, 5, 'Active'),
(7, 2, 6, '2024-04-03', '250mg', 'Three times daily', 10, 30, 0, 'Cancelled'),
(8, 8, 7, '2024-04-04', '1g', 'Once daily', 5, 5, 0, 'Active'),
(9, 6, 8, '2024-04-04', '2 puffs', 'Every 4 hours', 30, 1, 2, 'Active'),
(10, 10, 9, '2024-04-05', '400mg', 'Every 8 hours', 7, 21, 0, 'Active');

-- Transaction Tables

-- MedicalRecords (10 rows)
INSERT INTO MedicalRecords (PatientID, DoctorID, VisitDate, Diagnosis, Symptoms, TreatmentProvided, FollowUpRequired, FollowUpDate, Height, Weight, BloodPressure, HeartRate, Temperature, Notes) VALUES
(1, 1, '2024-04-01 09:00:00', 'Hypertension', 'High BP, headache', 'Prescribed medication', TRUE, '2024-05-01', 175.5, 80.2, '140/90', 78, 36.8, 'Monitor BP regularly'),
(2, 2, '2024-04-01 10:30:00', 'Migraine', 'Headache, dizziness', 'Pain management', FALSE, NULL, 162.3, 65.8, '120/80', 72, 36.6, 'Avoid triggers'),
(3, 3, '2024-04-01 11:15:00', 'Vaccination completed', 'None', 'Routine immunization', TRUE, '2024-10-01', 95.2, 18.5, '110/70', 85, 36.9, 'Next dose in 6 months'),
(4, 1, '2024-03-28 14:30:00', 'Angina', 'Chest pain', 'Nitroglycerin prescribed', TRUE, '2024-04-15', 180.1, 85.6, '150/95', 82, 37.1, 'Cardiac tests scheduled'),
(5, 4, '2024-03-29 16:00:00', 'Osteoarthritis', 'Knee pain', 'Pain relief medication', TRUE, '2024-04-20', 178.8, 92.3, '130/85', 76, 36.7, 'Consider physiotherapy'),
(6, 5, '2024-03-30 11:45:00', 'Annual checkup', 'None', 'Routine examination', FALSE, NULL, 165.4, 62.7, '118/78', 74, 36.5, 'Healthy, no issues'),
(7, 6, '2024-03-25 10:15:00', 'Sinusitis', 'Facial pain, congestion', 'Antibiotics prescribed', TRUE, '2024-04-08', 172.6, 78.9, '125/82', 79, 37.3, 'Follow up if symptoms persist'),
(8, 7, '2024-03-26 15:30:00', 'Pre-operative assessment', 'None', 'Cleared for surgery', TRUE, '2024-04-10', 169.2, 71.4, '122/79', 71, 36.8, 'Surgery scheduled'),
(9, 8, '2024-03-27 09:45:00', 'Contact dermatitis', 'Skin rash, itching', 'Topical cream prescribed', TRUE, '2024-04-12', 183.7, 88.5, '135/88', 77, 36.9, 'Avoid allergens'),
(10, 9, '2024-03-28 13:20:00', 'Anxiety disorder', 'Stress, sleep issues', 'Therapy sessions', TRUE, '2024-04-25', 176.3, 83.2, '128/84', 81, 37.0, 'Regular counseling needed');

-- LaboratoryResults (10 rows)
INSERT INTO LaboratoryResults (PatientID, TestID, DoctorID, TestDate, ResultValue, ResultUnit, NormalRange, Interpretation, Findings, ReviewedBy) VALUES
(1, 1, 1, '2024-04-01 10:00:00', '8.5', '10^9/L', '4.5-11.0', 'Normal', 'Normal CBC results', 1),
(2, 2, 2, '2024-04-01 11:30:00', '135', 'mg/dL', 'LDL: <100', 'Abnormal', 'High cholesterol detected', 2),
(3, 4, 3, '2024-04-01 12:15:00', '6.5', 'pH', '4.5-8.0', 'Normal', 'Normal urine analysis', 3),
(4, 3, 1, '2024-03-29 09:00:00', '65', 'U/L', '7-55', 'Abnormal', 'Elevated liver enzymes', 1),
(5, 5, 4, '2024-03-30 14:00:00', '2.8', 'mIU/L', '0.4-4.0', 'Normal', 'Normal thyroid function', 4),
(6, 9, 5, '2024-03-31 10:30:00', 'Positive', NULL, 'Negative', 'Abnormal', 'Pregnancy confirmed', 5),
(7, 8, 6, '2024-03-26 11:00:00', 'Negative', NULL, 'Negative', 'Normal', 'HIV test negative', 6),
(8, 10, 7, '2024-03-27 15:00:00', 'Negative', NULL, 'Negative', 'Normal', 'COVID-19 negative', 7),
(9, 1, 8, '2024-03-28 09:30:00', '12.5', '10^9/L', '4.5-11.0', 'Abnormal', 'Elevated WBC count', 8),
(10, 7, 9, '2024-03-29 13:45:00', '95', 'mg/dL', 'Fasting: <100', 'Normal', 'Normal glucose tolerance', 9);
-- Billing (10 rows)
INSERT INTO Billing (PatientID, AppointmentID, BillDate, TotalAmount, InsuranceCoverage, PatientPayment, PaymentStatus, DueDate) VALUES
(1, 1, '2024-04-01', 5000.00, 4000.00, 1000.00, 'Paid', '2024-04-15'),
(2, 2, '2024-04-01', 3500.00, 2800.00, 700.00, 'PartiallyPaid', '2024-04-15'),
(3, 3, '2024-04-01', 2000.00, 1500.00, 500.00, 'Paid', '2024-04-15'),
(4, NULL, '2024-04-02', 15000.00, 12000.00, 3000.00, 'InsuranceClaim', '2024-04-30'),
(5, NULL, '2024-04-02', 8000.00, 6000.00, 2000.00, 'Pending', '2024-04-30'),
(6, 6, '2024-04-03', 4500.00, 3500.00, 1000.00, 'Paid', '2024-04-20'),
(7, NULL, '2024-04-03', 12000.00, 9000.00, 3000.00, 'InsuranceClaim', '2024-04-25'),
(8, 8, '2024-04-04', 6000.00, 4800.00, 1200.00, 'Pending', '2024-04-25'),
(9, NULL, '2024-04-04', 3000.00, 2400.00, 600.00, 'Paid', '2024-04-20'),
(10, 10, '2024-04-05', 2500.00, 2000.00, 500.00, 'PartiallyPaid', '2024-04-30');

-- Admissions (8 rows)
INSERT INTO Admissions (PatientID, WardID, AdmittingDoctorID, AdmissionDate, DischargeDate, ReasonForAdmission, Diagnosis, Status, BedNumber) VALUES
(1, 1, 1, '2024-04-01 10:00:00', NULL, 'Cardiac monitoring', 'Hypertension crisis', 'Admitted', 'ICU-1'),
(4, 4, 4, '2024-04-02 08:30:00', NULL, 'Appendectomy surgery', 'Acute appendicitis', 'Admitted', 'SURG-3'),
(5, 6, 4, '2024-04-02 14:00:00', '2024-04-05 11:00:00', 'Knee replacement', 'Severe osteoarthritis', 'Discharged', 'ORTH-2'),
(6, 7, 5, '2024-04-03 09:15:00', NULL, 'Childbirth', 'Full term pregnancy', 'Admitted', 'MAT-5'),
(8, 4, 7, '2024-04-04 07:45:00', NULL, 'Cataract surgery', 'Bilateral cataracts', 'Admitted', 'SURG-1'),
(9, 2, 8, '2024-04-04 16:20:00', '2024-04-06 10:30:00', 'Skin treatment', 'Severe dermatitis', 'Discharged', 'GEN-12'),
(10, 8, 9, '2024-04-05 11:00:00', NULL, 'Psychiatric evaluation', 'Anxiety disorder', 'Admitted', 'PSY-7');


SHOW INDEXES FROM Patients;
CREATE INDEX idx_patient_nationalid ON Patients(NationalID);
CREATE INDEX idx_appointment_date ON Appointments(AppointmentDate);


-- Advanced Queries for Analysis

-- 1. Patient Demographics Analysis
SELECT 
    Gender,
    COUNT(*) as TotalPatients,
    AVG(YEAR(CURDATE()) - YEAR(DateOfBirth)) as AverageAge,
    BloodType,
    COUNT(*) as BloodTypeCount
FROM Patients 
GROUP BY Gender, BloodType 
ORDER BY Gender, BloodTypeCount DESC;

-- 2. Department-wise Staff Analysis
SELECT 
    d.DepartmentName,
    COUNT(sda.StaffID) as StaffCount,
    AVG(ms.YearsOfExperience) as AvgExperience,
    GROUP_CONCAT(DISTINCT ms.Specialization) as Specializations
FROM Departments d
LEFT JOIN StaffDepartmentAssignments sda ON d.DepartmentID = sda.DepartmentID
LEFT JOIN MedicalStaff ms ON sda.StaffID = ms.StaffID
GROUP BY d.DepartmentID, d.DepartmentName;

-- 3. Medication Inventory Management
SELECT 
    MedicationID,
    GenericName,
    BrandName,
    StockQuantity,
    ReorderLevel,
    CASE 
        WHEN StockQuantity <= ReorderLevel THEN 'Reorder Needed'
        WHEN StockQuantity <= ReorderLevel * 2 THEN 'Low Stock'
        ELSE 'Adequate Stock'
    END as StockStatus
FROM Medications
ORDER BY StockQuantity ASC;

-- 4. Patient Treatment History
SELECT 
    p.FirstName,
    p.LastName,
    COUNT(DISTINCT mr.RecordID) as TotalVisits,
    COUNT(DISTINCT pr.PrescriptionID) as Prescriptions,
    COUNT(DISTINCT tp.PlanID) as TreatmentPlans
FROM Patients p
LEFT JOIN MedicalRecords mr ON p.PatientID = mr.PatientID
LEFT JOIN Prescriptions pr ON p.PatientID = pr.PatientID
LEFT JOIN TreatmentPlans tp ON p.PatientID = tp.PatientID
GROUP BY p.PatientID, p.FirstName, p.LastName;

DESCRIBE MedicalStaff;
DESCRIBE Departments;

-- 5. Revenue Analysis by Department
SELECT 
    d.DepartmentName,
    COUNT(a.AppointmentID) as TotalAppointments,
    SUM(b.TotalAmount) as TotalRevenue,
    AVG(b.TotalAmount) as AvgBillAmount
FROM Departments d
LEFT JOIN MedicalStaff ms ON d.DepartmentName = ms.Department  -- Join on DepartmentName = Department enum
LEFT JOIN Appointments a ON ms.StaffID = a.DoctorID
LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID
GROUP BY d.DepartmentID, d.DepartmentName;


-- 6. Ward Utilization Analysis
SELECT 
    w.WardType,
    w.WardNumber,
    w.Capacity,
    w.CurrentOccupancy,
    ROUND((w.CurrentOccupancy * 100.0 / w.Capacity), 2) as UtilizationRate
FROM Wards w
ORDER BY UtilizationRate DESC;

-- 7. Insurance Coverage Analysis
SELECT 
    ic.CompanyName,
    COUNT(pi.InsuranceID) as CoveredPatients,
    AVG(pi.PremiumAmount) as AvgPremium,
    SUM(pi.DeductibleAmount) as TotalDeductibles
FROM InsuranceCompanies ic
LEFT JOIN PatientInsurance pi ON ic.CompanyID = pi.CompanyID
GROUP BY ic.CompanyID, ic.CompanyName;

-- Show table structure
DESCRIBE Patients;
DESCRIBE MedicalStaff;
DESCRIBE StaffDepartmentAssignments;
DESCRIBE PatientAllergies;
DESCRIBE PatientInsurance;
DESCRIBE TreatmentPlans;
DESCRIBE Prescriptions;
DESCRIBE MedicalRecords;
DESCRIBE LaboratoryResults;
DESCRIBE Billing;
DESCRIBE Admissions;
SELECT * FROM Appointments;


-- Count total tables
SELECT COUNT(*) as TotalTables FROM information_schema.tables 
WHERE table_schema = 'HealthcareManagementSystem';

-- View 1 – Summary / Aggregation_View
CREATE VIEW WardOccupancySummary AS
SELECT 
    w.WardID,
    w.WardNumber,
    w.WardType,
    w.Capacity,
    COUNT(a.AdmissionID) AS TotalPatients,
    ROUND((COUNT(a.AdmissionID) / w.Capacity) * 100, 2) AS OccupancyRate
FROM 
    Wards w
LEFT JOIN 
    Admissions a ON w.WardID = a.WardID AND a.Status = 'Admitted'
GROUP BY 
    w.WardID, w.WardNumber, w.WardType, w.Capacity;
    -- View 2 – Performance / Trend View
    CREATE VIEW DoctorMonthlyPerformance AS
SELECT 
    ms.StaffID,
    CONCAT(ms.FirstName, ' ', ms.LastName) AS DoctorName,
    DATE_FORMAT(a.AppointmentDate, '%Y-%m') AS Month,
    COUNT(CASE WHEN a.Status = 'Completed' THEN 1 END) AS CompletedAppointments,
    COUNT(CASE WHEN a.Status = 'Cancelled' THEN 1 END) AS CancelledAppointments,
    COUNT(a.AppointmentID) AS TotalAppointments
FROM 
    Appointments a
JOIN 
    MedicalStaff ms ON a.DoctorID = ms.StaffID
GROUP BY 
    ms.StaffID, Month
ORDER BY 
    Month DESC;
    -- To check views:
    SHOW FULL TABLES WHERE Table_type = 'VIEW';
    
SELECT * FROM WardOccupancySummary;
SELECT * FROM DoctorMonthlyPerformance;

-- JOIN Operations (Including Multi-Table Joins)
SELECT 
    p.PatientID,
    p.FirstName AS PatientFirstName,
    p.LastName AS PatientLastName,
    m.FirstName AS DoctorFirstName,
    m.LastName AS DoctorLastName,
    w.WardNumber,
    w.WardType
FROM Admissions a
INNER JOIN Patients p ON a.PatientID = p.PatientID
INNER JOIN MedicalStaff m ON a.AdmittingDoctorID = m.StaffID
INNER JOIN Wards w ON a.WardID = w.WardID;
-- Aggregation with GROUP BY
SELECT 
    w.WardNumber,
    w.WardType,
    COUNT(a.PatientID) AS TotalPatients
FROM Wards w
LEFT JOIN Admissions a ON w.WardID = a.WardID
GROUP BY w.WardID, w.WardNumber, w.WardType;
-- -- Aggregation with HAVING

SELECT 
    w.WardNumber,
    COUNT(a.PatientID) AS TotalPatients
FROM Wards w
LEFT JOIN Admissions a ON w.WardID = a.WardID
GROUP BY w.WardID, w.WardNumber
HAVING COUNT(a.PatientID) > 10;
-- Conditional Logic Using CASE
SELECT 
    p.PatientID,
    p.FirstName,
    p.LastName,
    mr.Weight / ((mr.Height/100)*(mr.Height/100)) AS BMI,
    CASE
        WHEN mr.Weight / ((mr.Height/100)*(mr.Height/100)) < 18.5 THEN 'Underweight'
        WHEN mr.Weight / ((mr.Height/100)*(mr.Height/100)) BETWEEN 18.5 AND 24.9 THEN 'Normal'
        WHEN mr.Weight / ((mr.Height/100)*(mr.Height/100)) BETWEEN 25 AND 29.9 THEN 'Overweight'
        ELSE 'Obese'
    END AS BMICategory
FROM MedicalRecords mr
INNER JOIN Patients p ON mr.PatientID = p.PatientID;
-- non Correlated subquery
SELECT PatientID, FirstName, LastName
FROM Patients
WHERE PatientID IN (
    SELECT PatientID
    FROM Appointments
    WHERE AppointmentDate > '2025-01-01'
);
-- Correlated subquery
SELECT p.PatientID, p.FirstName, p.LastName, b.TotalAmount
FROM Billing b
INNER JOIN Patients p ON b.PatientID = p.PatientID
WHERE b.TotalAmount > (
    SELECT AVG(TotalAmount)
    FROM Billing
);

-- Window Functions for Rankings or Trends

SELECT 
    p.PatientID,
    p.FirstName,
    p.LastName,
    b.TotalAmount,
    RANK() OVER (PARTITION BY b.PatientID ORDER BY b.TotalAmount DESC) AS BillingRank
FROM Billing b
INNER JOIN Patients p ON b.PatientID = p.PatientID;

SELECT 
    p.PatientID,
    p.FirstName,
    p.LastName,
    b.BillDate,
    b.TotalAmount,
    SUM(b.TotalAmount) OVER (PARTITION BY p.PatientID ORDER BY b.BillDate) AS RunningTotal
FROM Billing b
INNER JOIN Patients p ON b.PatientID = p.PatientID;




SELECT 
    p.PatientID, p.FirstName, p.LastName,
    m.FirstName AS DoctorFirstName, m.LastName AS DoctorLastName,
    a.AdmissionDate, a.DischargeDate
FROM Admissions a
INNER JOIN Patients p ON a.PatientID = p.PatientID
INNER JOIN MedicalStaff m ON a.AdmittingDoctorID = m.StaffID
WHERE a.AdmissionDate BETWEEN '2025-01-01' AND '2025-03-31';

CREATE INDEX idx_admissions_date_patient_doctor
ON Admissions (AdmissionDate, PatientID, AdmittingDoctorID);

SELECT 
    p.PatientID, p.FirstName, p.LastName,
    (SELECT m.FirstName FROM MedicalStaff m WHERE m.StaffID = a.AdmittingDoctorID) AS DoctorFirstName,
    (SELECT m.LastName FROM MedicalStaff m WHERE m.StaffID = a.AdmittingDoctorID) AS DoctorLastName,
    a.AdmissionDate, a.DischargeDate
FROM Patients p
INNER JOIN Admissions a ON p.PatientID = a.PatientID
WHERE a.AdmissionDate BETWEEN '2025-01-01' AND '2025-03-31'
AND EXISTS (SELECT 1 FROM MedicalStaff m WHERE m.StaffID = a.AdmittingDoctorID);


