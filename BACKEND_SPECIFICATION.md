# CardVault: Backend & Architecture Specification

This document outlines the current functionality of the CardVault app and provides a comprehensive guide for building the backend infrastructure (optimized for **Supabase**).

---

## 1. App Overview
CardVault is a premium business card scanner that uses on-device OCR and cloud-based AI to digitize contacts. It allows users to organize contacts into folders and export them to Excel for professional use.

### Core Workflows:
1.  **Scanning**: Capture front and back of a card using Google ML Kit (On-device).
2.  **Extraction**: Extract text from images (OCR).
3.  **Parsing**: Convert raw text into structured JSON using Groq AI (Llama 3.3 70B).
4.  **Organization**: Save contacts into user-defined folders.
5.  **Export**: Generate and share Excel files based on folder contents.

---

## 2. Current Frontend Stack
- **Framework**: Flutter (Dart)
- **State Management**: BLoC / Cubit
- **DI**: GetIt
- **OCR**: Google ML Kit Text Recognition (On-device)
- **AI Engine**: Groq Cloud API (High-speed LPUs)
- **UI Style**: Modern Glassmorphism (Custom Implementation)

---

## 3. Recommended Backend Structure (Supabase)

To move from the current "In-Memory" repository to a real database, you should implement the following structure:

### A. Authentication
- **Provider**: Supabase Auth (Email/Password or Google Sign-In).
- **Security**: All database rows must be protected by **Row Level Security (RLS)** so users can only see their own folders and cards.

### B. Database Schema (PostgreSQL)

#### Table: `folders`
Stores the categorization containers created by users.
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | uuid | Primary Key (Default: uuid_generate_v4()) |
| `user_id` | uuid | Foreign Key to auth.users.id |
| `name` | text | Name of the folder (e.g., "Tech Conf 2026") |
| `description` | text | Optional notes |
| `created_at` | timestamptz | Timestamp of creation |

#### Table: `contacts`
Stores the actual digitized card data.
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | uuid | Primary Key |
| `user_id` | uuid | Foreign Key to auth.users.id |
| `folder_id` | uuid | Foreign Key to folders.id (ON DELETE CASCADE) |
| `name` | text | Extracted Full Name |
| `company` | text | Company Name |
| `job_title` | text | Job Title |
| `email` | text | Email Address |
| `phone` | text | Phone Number |
| `website` | text | Website URL |
| `address` | text | Physical Address |
| `linkedin` | text | LinkedIn Profile URL |
| `social_handles`| jsonb | Map of other handles (Twitter, IG, etc.) |
| `front_image_url`| text | Public URL to the front card image in Storage |
| `back_image_url` | text | Public URL to the back card image in Storage |
| `created_at` | timestamptz | Timestamp of creation |

### C. Storage (Supabase Storage)
- **Bucket Name**: `card-images`
- **Pathing**: `user_id/folder_id/contact_id_front.jpg`
- **Access**: Private (Authenticated users only)

---

## 4. Integration Steps for Flutter

1.  **Initialize SDK**: Add `supabase_flutter` to `pubspec.yaml`.
2.  **Auth Guard**: Update `AuthScreen` to verify credentials against Supabase.
3.  **Repository Refactor**:
    - Replace `ContactRepository` (in-memory) with a `SupabaseRepository`.
    - Use `supabase.from('folders').select()` to load dashboard data.
    - Use `supabase.from('contacts').insert()` to save new cards.
4.  **Image Upload**:
    - In `ResultScreen`, before saving the record, upload the local file to Supabase Storage.
    - Retrieve the `publicUrl` and save it in the `contacts` table.

---

## 5. Security Checklist
- [ ] Enable RLS on all tables.
- [ ] Add policy: `(role() = 'authenticated')` for SELECT/INSERT/UPDATE.
- [ ] Add policy: `(auth.uid() = user_id)` to ensure data isolation.
- [ ] Set up Storage Bucket policies to match user ownership.

---

## 6. Future-Proofing
- **Search**: For large volumes, use PostgreSQL's `tsvector` for full-text search across company and names.
- **Batch Export**: The current `ExcelService` runs on the client. For thousands of cards, consider a Supabase Edge Function to generate the Excel on the server.
