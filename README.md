# Pegasus Field App – Consolidated Requirements

## 1. Lead Management Enhancements

### 1.1 Multiple Proposal Uploads

* In the Lead section, when a lead reaches the **Proposal** stage, Field Executives should be able to upload **multiple proposal documents** for the same lead.
* Each proposal should have its own status:

  * Won
  * Lost
* Proposal history must be maintained for each lead.

### 1.2 Lead Status Classification

Add a separate **Status** feature independent of the existing lead stages.

#### Existing Lead Stages

* New
* Contacted
* Qualified
* Proposal
* Won
* Lost

#### Status Categories

* Hot – High-priority leads requiring immediate attention.
* Warm – Leads with active and regular communication.
* Cold – Leads with little or no response.

#### Functional Changes

* Add a **Status dropdown** below the existing lead-stage dropdown.
* Available options:

  * Hot
  * Warm
  * Cold
* Create a separate **Status tab** in the Lead module.
* The Status tab should display all leads categorized as Hot, Warm, or Cold.
* Any status selected for a lead must automatically reflect in the Status tab.
* A lead can simultaneously have:

  * A Lead Stage (e.g., Proposal)
  * A Lead Status (e.g., Hot)

---

## 2. Task Management Enhancements

### Task Completion Rules

* Once a task is marked as **Completed**, it:

  * Cannot be deleted.
  * Cannot be reverted to Pending.

### Task Editing Rules

* Pending tasks should remain editable.
* Users should be able to modify:

  * Title
  * Description
  * Date
  * Time
  * Other task details

### Overdue Tasks

* Missed/Overdue tasks should be editable to allow rescheduling and updates.

---

## 3. Profile Management Restrictions

* Email ID and Phone Number must be mandatory during account creation.
* After account creation:

  * Email ID cannot be edited.
  * Phone Number cannot be edited.
* Other profile fields may remain editable.

---

## 4. Account Creation Enhancements

* Add a **Role** dropdown during account creation.
* Supported roles:

  * Field Executive
  * Manager

---

## 5. Manager Assignment & Administration

### Admin Permissions

* Admin should be able to assign Field Executives to Managers.

### Managers Tab

Create a dedicated Managers tab displaying:

* List of Managers.
* Number of Field Executives assigned to each Manager.
* Manager assignment details.

---

## 6. Manager Panel Development

Create a dedicated Manager Panel similar to the Admin Panel with role-based access restrictions.

### Manager Capabilities

* View assigned Field Executives only.
* View leads, tasks, and activities of assigned team members only.
* Assign tasks to assigned Field Executives.
* Monitor team performance and activities.

### Access Restrictions

* Managers must not have access to data belonging to other Managers or their teams.

---

## 7. Forgot Password & Security Enhancements

### OTP Changes

* Reduce OTP validity from 10 minutes to 5 minutes.
* Display a visible countdown timer on the OTP verification screen.

### Resend OTP

* Add a **Resend OTP** option.
* Users should be able to request a new OTP after expiration.
* A new OTP should be generated and sent to the registered email/mobile number.

### Password Policy

Passwords must contain:

* Minimum 8 characters.
* At least one uppercase letter.
* At least one lowercase letter.
* At least one number.
* At least one special character.

Display validation messages while creating or resetting passwords.

---

## 8. Data Export Functionality

### Manager Access

Managers should be able to export data related only to their assigned Field Executives, including:

* Leads
* Proposals
* Tasks
* Activity history
* Performance records

### Admin Access

Admins should be able to export:

* Employee details
* Leads
* Proposals
* Tasks
* Activity logs
* System records

### Export Options

* Provide an Export Data option in Admin and Manager panels.
* Supported formats:

  * Excel (.xlsx)
  * CSV (.csv)

### Access Control

* Field Executives must not have export permissions.
* Export functionality should be restricted to Managers and Admins.

---

## 9. Expense & Expense Form Module Enhancements

### 9.1 Expense Module

#### File Attachment Fix

* Fix the file attachment functionality in the Expenses section.
* Users should be able to upload supporting documents successfully.
* Expense submission should work correctly once attachments are uploaded.

#### UI Enhancement

* Replicate the Tasks module design.
* Display:

  * List of all created expenses.
  * "+" (Add Expense) button at the bottom corner.

#### Expense Creation

* Clicking "+" should open the Expense Creation Form.
* Newly created expenses should appear in the list view.

### 9.2 Expense Form Module

#### File Attachment Fix

* Fix the file upload functionality in the Expense Form section.
* Users should be able to upload bills, invoices, receipts, and supporting documents without issues.

#### UI Enhancement

* Replicate the Tasks module design.
* Display:

  * List of all submitted expense forms.
  * "+" (Add Expense Form) button at the bottom corner.

#### Expense Form Creation

Users should be able to enter:

* Expense Category (Food, Travel, Accommodation, etc.)
* Amount
* Description/Remarks
* Supporting Attachment

After submission, the expense form should appear in the list view.

### Expected Outcome

Both Expenses and Expense Forms should function similarly to the Tasks module:

* List view of records.
* "+" button for creating new entries.
* Fully functional file uploads.
* Newly created records visible immediately after submission.
* Consistent UI and user experience.
