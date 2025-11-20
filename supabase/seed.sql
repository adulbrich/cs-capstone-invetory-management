-- Seed data for inventory management system
-- This file creates sample data for development and testing

-- Clear existing data
TRUNCATE items, transactions CASCADE;

-- Create admin user
-- Note: In Supabase, we need to use the auth schema for user creation
-- The password is hashed using Supabase's crypt extension
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '2944d9a8-ba10-4658-bdc6-4ea3175aadd3',
  'authenticated',
  'authenticated',
  'alex@example.com',
  crypt('alex1234', gen_salt('bf')), -- Password: alex1234
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"email_verified":true}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
);

-- Update the auto-created profile to admin role
-- The trigger on_auth_user_created automatically creates a profile with 'student' role
-- We update it to 'admin' and set the full name
UPDATE profiles
SET role = 'admin', full_name = 'Alex Admin'
WHERE id = '2944d9a8-ba10-4658-bdc6-4ea3175aadd3';

-- Insert sample items
INSERT INTO items (title, description, tags, status, location, notes, image_url) VALUES
  ('Raspberry Pi 4 Model B (4GB)', 
   '4GB RAM, Quad-core Cortex-A72 (ARM v8) 64-bit SoC @ 1.5GHz. Perfect for IoT projects and learning embedded systems.',
   ARRAY['SBC', 'IoT', 'Raspberry Pi', 'ARM'],
   'checked_in',
   'Cabinet A, Shelf 2, Bin 3',
   'Includes official power supply and 32GB microSD card with Raspberry Pi OS',
   NULL),

  ('Arduino Uno R3', 
   'ATmega328P based microcontroller board with 14 digital I/O pins and 6 analog inputs. Great for beginners.',
   ARRAY['Microcontroller', 'Arduino', 'Embedded', 'Education'],
   'checked_out',
   'Cabinet A, Shelf 1, Bin 1',
   'Checked out to Team Phoenix for autonomous robot project. Return date: 2025-12-15',
   NULL),

  ('NVIDIA Jetson Nano Developer Kit', 
   'Small, powerful computer for AI development with quad-core ARM CPU and 128-core Maxwell GPU.',
   ARRAY['AI', 'NVIDIA', 'SBC', 'Machine Learning', 'GPU'],
   'checked_in',
   'Cabinet B, Shelf 3, Bin 2',
   'Includes 5V 4A barrel jack power supply. Requires microSD card (not included)',
   NULL),

  ('Logitech C920 HD Pro Webcam', 
   'HD Pro Webcam with 1080p video calling and recording. Auto-focus and noise-reducing mic.',
   ARRAY['Peripherals', 'Camera', 'USB', 'Video'],
   'checked_in',
   'Cabinet C, Shelf 1, Drawer A',
   'USB-A connection. Compatible with Windows, Mac, and Linux',
   NULL),

  ('Meta Quest 2 VR Headset (128GB)', 
   'All-in-one VR headset with wireless PC connectivity. Includes two touch controllers.',
   ARRAY['VR', 'Headset', 'Meta', 'Gaming', 'XR'],
   'checked_in',
   'Cabinet D, Shelf 1, Locked Box',
   'Accessories: Carrying case, USB-C charging cable, controller batteries included',
   NULL),

  ('ESP32 Development Board', 
   'Dual-core WiFi and Bluetooth enabled microcontroller for IoT applications.',
   ARRAY['Microcontroller', 'IoT', 'WiFi', 'Bluetooth', 'ESP32'],
   'checked_in',
   'Cabinet A, Shelf 1, Bin 5',
   'Package of 5 boards. Programmable via Arduino IDE or ESP-IDF',
   NULL),

  ('Elegoo Mars 3 Pro 3D Printer', 
   'MSLA 3D resin printer with 6.6" 4K monochrome LCD and fast printing speeds.',
   ARRAY['3D Printing', 'Resin', 'Manufacturing', 'Prototyping'],
   'checked_out',
   'Maker Space, Station 2',
   'Checked out to Team Alpha for product design project. Includes 1kg of gray resin',
   NULL),

  ('Anker PowerCore 20000mAh Battery', 
   'High-capacity portable charger with dual USB ports and fast charging capability.',
   ARRAY['Power', 'Battery', 'USB', 'Portable'],
   'checked_in',
   'Cabinet C, Shelf 2, Bin 1',
   'Fully charged. Includes micro-USB charging cable',
   NULL),

  ('Soldering Station Kit', 
   'Digital temperature-controlled soldering station with adjustable iron and accessories.',
   ARRAY['Tools', 'Soldering', 'Electronics', 'Hardware'],
   'checked_in',
   'Tool Cabinet, Drawer 3',
   'Includes solder wire, flux, cleaning sponge, and tip cleaner',
   NULL),

  ('Tektronix TBS1052B Oscilloscope', 
   'Digital oscilloscope with 50 MHz bandwidth and 2 channels. Essential for electronics debugging.',
   ARRAY['Test Equipment', 'Oscilloscope', 'Measurement', 'Electronics'],
   'checked_in',
   'Lab Bench 5',
   'Includes two 100 MHz probes. Calibrated on 2025-10-01',
   NULL),

  ('HTC Vive Pro VR System', 
   'Professional-grade VR system with room-scale tracking (Base Stations 2.0).',
   ARRAY['VR', 'Headset', 'HTC', 'Professional', 'XR'],
   'retired',
   'Storage Room, Shelf C',
   'Controllers showing battery drain issues. Replaced by Quest 2 units',
   NULL),

  ('BeagleBone Black', 
   'Linux-enabled development board with AM335x 1GHz ARM processor.',
   ARRAY['SBC', 'Embedded', 'Linux', 'ARM'],
   'checked_in',
   'Cabinet B, Shelf 1, Bin 4',
   'Pre-loaded with Debian Linux. Includes USB cable',
   NULL),

  ('Raspberry Pi Camera Module v2', 
   '8 megapixel camera module compatible with all Raspberry Pi models.',
   ARRAY['Camera', 'Raspberry Pi', 'Vision', 'Hardware'],
   'checked_in',
   'Cabinet A, Shelf 3, Small Parts Drawer',
   'Package of 3 modules. Includes ribbon cables',
   NULL),

  ('Multimeter - Fluke 115', 
   'Professional digital multimeter for electronics troubleshooting and testing.',
   ARRAY['Tools', 'Multimeter', 'Test Equipment', 'Measurement'],
   'checked_in',
   'Tool Cabinet, Drawer 1',
   'Includes test leads and 9V battery',
   NULL),

  ('Logic Analyzer - Saleae Logic 8', 
   '8-channel USB logic analyzer for digital signal debugging up to 100 MS/s.',
   ARRAY['Test Equipment', 'Logic Analyzer', 'Debugging', 'Digital'],
   'checked_in',
   'Lab Bench 3, Drawer',
   'Includes USB cable and test clips. Software downloadable from Saleae website',
   NULL);

-- Log the seed operation
DO $$
BEGIN
  RAISE NOTICE 'Seed data inserted successfully. Total items: %', (SELECT COUNT(*) FROM items);
END $$;
