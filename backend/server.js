/**
 * CampusVerse — Collegiate Event Management REST API Server
 * 
 * Production-ready Express microservice implementing authentication,
 * event CRUD, registration with UUID passes, atomic ticket verification,
 * and duplicate check-in prevention.
 */

const express = require('express');
const cors = require('cors');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// In-Memory Database Store (with sample academic seeds)
const db = {
  users: [
    {
      id: 'usr-org-1',
      name: 'CampusVerse Admin',
      email: 'admin@gmail.com',
      role: 'organizer',
      salt: 'salt_admin_demo',
      passwordHash: hashPassword('admin', 'salt_admin_demo')
    },
    {
      id: 'usr-stu-1',
      name: 'Alex Chen',
      email: 'alex.chen@campusverse.edu',
      rollNumber: 'CS-2023-042',
      department: 'Computer Science & Engineering',
      yearOfStudy: '3rd Year (Junior)',
      phone: '+91 98765 43210',
      role: 'student',
      salt: 'salt_alex_2026',
      passwordHash: hashPassword('Password@123', 'salt_alex_2026')
    }
  ],
  events: [
    {
      id: 'event-001',
      title: 'HackCampus 2026 — 24H Collegiate Hackathon',
      description: 'The flagship annual 24-hour hackathon for student builders, designers, and innovators.',
      category: 'Hackathons',
      venue: 'Innovation Hub, Hall A & B',
      organizer: 'Computer Science Society',
      dateTime: new Date(Date.now() + 5 * 86400000).toISOString(),
      endTime: new Date(Date.now() + 6 * 86400000).toISOString(),
      capacity: 120,
      registeredCount: 14,
      imageUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
      registrationDeadline: new Date(Date.now() + 3 * 86400000).toISOString(),
      isFeatured: true
    },
    {
      id: 'event-002',
      title: 'AI & Generative Deep Learning Workshop',
      description: 'Deep dive into transformer architectures, diffusion models, and local LLM fine-tuning.',
      category: 'Workshops',
      venue: 'Turing Computer Lab 3',
      organizer: 'AI Student Chapter',
      dateTime: new Date(Date.now() + 7 * 86400000).toISOString(),
      endTime: new Date(Date.now() + 7 * 86400000 + 4 * 3600000).toISOString(),
      capacity: 60,
      registeredCount: 42,
      imageUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
      registrationDeadline: new Date(Date.now() + 5 * 86400000).toISOString(),
      isFeatured: true
    },
    {
      id: 'event-003',
      title: 'Pulse 2026 — Annual Cultural Fest',
      description: 'Two nights of live collegiate band battles, choreography showcases, and food carnivals.',
      category: 'Cultural',
      venue: 'Main Campus Open Air Amphitheatre',
      organizer: 'Student Cultural Council',
      dateTime: new Date(Date.now() + 12 * 86400000).toISOString(),
      endTime: new Date(Date.now() + 14 * 86400000).toISOString(),
      capacity: 500,
      registeredCount: 310,
      imageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800',
      registrationDeadline: new Date(Date.now() + 10 * 86400000).toISOString(),
      isFeatured: false
    }
  ],
  registrations: []
};

// Helper: Salted SHA-256 password hash
function hashPassword(password, salt) {
  return crypto.createHash('sha256').update(`${salt}:${password}:campusverse_academic_salt_2026`).digest('hex');
}

// Helper: Extract registration ID from raw QR text
function extractRegistrationId(raw) {
  if (!raw) return '';
  const text = raw.trim();
  if (text.startsWith('CAMPUSVERSE:TICKET:')) {
    return text.substring('CAMPUSVERSE:TICKET:'.length).trim().toUpperCase();
  }
  return text.toUpperCase();
}

// ---------------- HEALTH CHECK ----------------
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'CampusVerse REST API Backend',
    timestamp: new Date().toISOString(),
    eventsCount: db.events.length,
    registrationsCount: db.registrations.length
  });
});

// ---------------- EVENTS ENDPOINTS ----------------

// GET /api/v1/events
app.get('/api/v1/events', (req, res) => {
  const { category, search } = req.query;
  let results = [...db.events];

  if (category && category !== 'All Events') {
    results = results.filter(e => e.category.toLowerCase() === category.toLowerCase());
  }
  if (search) {
    const q = search.toLowerCase();
    results = results.filter(e => e.title.toLowerCase().includes(q) || e.description.toLowerCase().includes(q));
  }

  res.json({ success: true, count: results.length, data: results });
});

// GET /api/v1/events/:id
app.get('/api/v1/events/:id', (req, res) => {
  const event = db.events.find(e => e.id === req.params.id);
  if (!event) {
    return res.status(404).json({ success: false, message: 'Event not found' });
  }
  res.json({ success: true, data: event });
});

// POST /api/v1/events (Organizer CRUD)
app.post('/api/v1/events', (req, res) => {
  const { title, description, category, venue, capacity, imageUrl } = req.body;
  if (!title || !venue || !capacity) {
    return res.status(400).json({ success: false, message: 'Title, venue, and capacity are required.' });
  }

  const newEvent = {
    id: `event-${Date.now().toString(36)}`,
    title: title.trim(),
    description: description || '',
    category: category || 'Technical',
    venue: venue.trim(),
    organizer: req.body.organizer || 'Campus Event Office',
    dateTime: req.body.dateTime || new Date(Date.now() + 7 * 86400000).toISOString(),
    endTime: req.body.endTime || new Date(Date.now() + 7 * 86400000 + 3 * 3600000).toISOString(),
    capacity: parseInt(capacity, 10),
    registeredCount: 0,
    imageUrl: imageUrl || 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
    registrationDeadline: req.body.registrationDeadline || new Date(Date.now() + 5 * 86400000).toISOString(),
    isFeatured: false
  };

  db.events.unshift(newEvent);
  res.status(201).json({ success: true, data: newEvent });
});

// DELETE /api/v1/events/:id
app.delete('/api/v1/events/:id', (req, res) => {
  const index = db.events.findIndex(e => e.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Event not found' });
  }
  db.events.splice(index, 1);
  res.json({ success: true, message: 'Event deleted successfully' });
});

// ---------------- AUTHENTICATION ENDPOINTS ----------------

// POST /api/v1/auth/register
app.post('/api/v1/auth/register', (req, res) => {
  const { name, email, rollNumber, department, yearOfStudy, phone, password } = req.body;
  if (!name || !email || !rollNumber || !password) {
    return res.status(400).json({ success: false, message: 'All required registration fields must be provided.' });
  }

  const normEmail = email.trim().toLowerCase();
  const normRoll = rollNumber.trim().toLowerCase();

  if (db.users.some(u => u.email && u.email.toLowerCase() === normEmail)) {
    return res.status(409).json({ success: false, message: `Email "${email}" is already registered.` });
  }
  if (db.users.some(u => u.rollNumber && u.rollNumber.toLowerCase() === normRoll)) {
    return res.status(409).json({ success: false, message: `Roll number "${rollNumber}" is already registered.` });
  }

  const salt = crypto.randomBytes(16).toString('hex');
  const passwordHash = hashPassword(password, salt);

  const newUser = {
    id: `usr-${Date.now().toString(36)}`,
    name: name.trim(),
    email: normEmail,
    rollNumber: normRoll,
    department: department || 'General Engineering',
    yearOfStudy: yearOfStudy || '1st Year',
    phone: phone || '',
    role: 'student',
    salt,
    passwordHash
  };

  db.users.push(newUser);

  // Return sanitized user without salt or passwordHash
  const sanitized = { ...newUser };
  delete sanitized.salt;
  delete sanitized.passwordHash;

  res.status(201).json({
    success: true,
    message: 'Student registered successfully',
    data: sanitized,
    token: `cv_token_${crypto.randomUUID()}`
  });
});

// POST /api/v1/auth/login
app.post('/api/v1/auth/login', (req, res) => {
  const { identifier, password } = req.body;
  if (!identifier || !password) {
    return res.status(400).json({ success: false, message: 'Identifier and password are required.' });
  }

  const q = identifier.trim().toLowerCase();
  const user = db.users.find(u => (u.email && u.email.toLowerCase() === q) || (u.rollNumber && u.rollNumber.toLowerCase() === q));

  if (!user) {
    return res.status(401).json({ success: false, message: 'Invalid credentials. No matching account found.' });
  }

  const checkHash = hashPassword(password, user.salt);
  if (checkHash !== user.passwordHash) {
    return res.status(401).json({ success: false, message: 'Incorrect password. Please verify and try again.' });
  }

  const sanitized = { ...user };
  delete sanitized.salt;
  delete sanitized.passwordHash;

  res.json({
    success: true,
    message: 'Authenticated successfully',
    data: sanitized,
    token: `cv_token_${crypto.randomUUID()}`
  });
});

// ---------------- REGISTRATIONS & TICKETS ENDPOINTS ----------------

// POST /api/v1/events/:id/register
app.post('/api/v1/events/:id/register', (req, res) => {
  const event = db.events.find(e => e.id === req.params.id);
  if (!event) {
    return res.status(404).json({ success: false, message: 'Event not found.' });
  }

  const { student, teamName } = req.body;
  if (!student || !student.rollNumber) {
    return res.status(400).json({ success: false, message: 'Student roll number and profile are required.' });
  }

  const normRoll = student.rollNumber.trim().toLowerCase();

  // Duplicate check
  const duplicate = db.registrations.some(
    r => r.eventId === event.id && r.student.rollNumber.trim().toLowerCase() === normRoll && r.status !== 'cancelled'
  );
  if (duplicate) {
    return res.status(409).json({
      success: false,
      message: `Student (${student.rollNumber}) is already registered for "${event.title}".`
    });
  }

  // Generate collision-resistant UUID registration ID
  const shortUuid = crypto.randomUUID().substring(0, 8).toUpperCase();
  const regId = `CV-${new Date().getFullYear()}-${shortUuid}`;
  const qrData = `CAMPUSVERSE:TICKET:${regId}`;

  const registration = {
    registrationId: regId,
    eventId: event.id,
    eventTitle: event.title,
    eventVenue: event.venue,
    eventDate: event.dateTime,
    student: {
      name: student.name,
      email: student.email,
      rollNumber: student.rollNumber,
      department: student.department,
      yearOfStudy: student.yearOfStudy,
      phone: student.phone
    },
    teamName: teamName || null,
    registeredAt: new Date().toISOString(),
    status: 'confirmed',
    isCheckedIn: false,
    checkedInAt: null,
    qrCodeData: qrData
  };

  db.registrations.unshift(registration);
  event.registeredCount += 1;

  res.status(201).json({ success: true, data: registration });
});

// GET /api/v1/registrations (filter by studentRoll or eventId)
app.get('/api/v1/registrations', (req, res) => {
  const { studentRoll, eventId } = req.query;
  let list = [...db.registrations];

  if (studentRoll) {
    const q = studentRoll.trim().toLowerCase();
    list = list.filter(r => r.student.rollNumber.trim().toLowerCase() === q);
  }
  if (eventId) {
    list = list.filter(r => r.eventId === eventId);
  }

  res.json({ success: true, count: list.length, data: list });
});

// POST /api/v1/tickets/verify (Atomic server ticket verification)
app.post('/api/v1/tickets/verify', (req, res) => {
  const { rawInput, targetEventId } = req.body;
  if (!rawInput) {
    return res.status(400).json({ status: 'invalidFormat', message: 'Empty ticket payload.', canCheckIn: false });
  }

  const regId = extractRegistrationId(rawInput);
  const reg = db.registrations.find(r => r.registrationId === regId);

  if (!reg) {
    return res.json({
      status: 'notFound',
      message: `No registration found for ID: ${regId}`,
      canCheckIn: false
    });
  }

  if (reg.status === 'cancelled') {
    return res.json({
      status: 'cancelled',
      message: 'This registration pass was cancelled and is invalid for entry.',
      registration: reg,
      canCheckIn: false
    });
  }

  if (reg.isCheckedIn || reg.status === 'attended') {
    return res.json({
      status: 'alreadyCheckedIn',
      message: `Ticket already checked in at ${new Date(reg.checkedInAt).toLocaleTimeString()}! Repeated entry blocked.`,
      registration: reg,
      canCheckIn: false
    });
  }

  if (targetEventId && reg.eventId !== targetEventId) {
    return res.json({
      status: 'eventMismatch',
      message: `Ticket is registered for "${reg.eventTitle}", which does not match the active check-in gate.`,
      registration: reg,
      canCheckIn: false
    });
  }

  return res.json({
    status: 'valid',
    message: `Verified admission pass for ${reg.student.name} (${reg.student.rollNumber}).`,
    registration: reg,
    canCheckIn: true
  });
});

// POST /api/v1/tickets/check-in (Atomic gate check-in update)
app.post('/api/v1/tickets/check-in', (req, res) => {
  const { registrationId } = req.body;
  if (!registrationId) {
    return res.status(400).json({ success: false, message: 'registrationId is required.' });
  }

  const normId = extractRegistrationId(registrationId);
  const reg = db.registrations.find(r => r.registrationId === normId);

  if (!reg) {
    return res.status(404).json({ success: false, message: 'Registration not found.' });
  }

  if (reg.status === 'cancelled') {
    return res.status(400).json({ success: false, message: 'Cannot check in cancelled registration.' });
  }

  if (reg.isCheckedIn || reg.status === 'attended') {
    return res.status(409).json({ success: false, message: 'Ticket already checked in earlier.' });
  }

  // Atomically record admission
  reg.isCheckedIn = true;
  reg.checkedInAt = new Date().toISOString();
  reg.status = 'attended';

  res.json({
    success: true,
    message: `Successfully checked in ${reg.student.name}`,
    data: reg
  });
});

// Start Express Server
app.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(` CampusVerse REST API Server running on port ${PORT}`);
  console.log(` Health check: http://localhost:${PORT}/health`);
  console.log(` Events API:   http://localhost:${PORT}/api/v1/events`);
  console.log(`=======================================================`);
});
