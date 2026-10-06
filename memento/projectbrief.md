# Project Brief — Shutterfly Agenda

## Project Name
Shutterfly Annual Celebration — Event App

## Purpose
A Flutter mobile application for Shutterfly's internal annual celebration event. Employees use it to:
- View the 3-day event agenda
- Upload and browse photos from the celebration
- Vote for best traditional attire (one vote per employee)
- Browse the potluck menu
- Explore sweets via QR-code scanning

## Scope
Full-stack: Flutter frontend + Node.js/Express/MongoDB backend.

## Core Requirements
1. Multi-user authentication (mock credentials, shared_preferences session)
2. Persistent photo gallery shared across all users (MongoDB + disk storage)
3. Persistent voting shared across all users (one vote per employee, enforced by DB unique index)
4. 3-day agenda timeline
5. Potluck menu display
6. Sweets showcase with QR scanning (mobile_scanner)
7. Clean architecture (BLoC + Repository pattern)

## Out of Scope
- Real auth server / OAuth
- Push notifications
- Admin panel