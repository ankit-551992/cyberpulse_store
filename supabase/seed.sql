-- ==============================================================================
-- ⚡ CYBERPULSE STORE: SUPABASE SEED DATA
-- Default Cyberpunk Catalog, Categories, Initial Orders & Inventory Logs
-- ==============================================================================

-- 1. SEED CATEGORIES
INSERT INTO public.categories (id, name, slug, description, icon_code_point, gradient_colors, featured, is_active)
VALUES
('cat-laptops', 'Laptops', 'laptops', 'Next-gen ultrabooks, AI workstations & high-performance rigs.', 58234, '["0xFF00F0FF", "0xFF0072FF"]'::jsonb, true, true),
('cat-smartphones', 'Smartphones', 'smartphones', 'Cybernetic flagship devices with high refresh holographic displays.', 58546, '["0xFF7000FF", "0xFFFF007A"]'::jsonb, true, true),
('cat-audio', 'Audio', 'audio', 'Spatial acoustic headphones, quantum buds & audiophile DACs.', 58098, '["0xFFFF007A", "0xFFFF9900"]'::jsonb, true, true),
('cat-wearables', 'Wearables', 'wearables', 'Biometric health rings, neural sync wristbands & smart chronos.', 59105, '["0xFF00F5A0", "0xFF00F0FF"]'::jsonb, true, true),
('cat-gaming', 'Gaming & VR', 'gaming-vr', 'Haptic feedback rigs, 8K micro-OLED goggles & ultra controllers.', 59069, '["0xFFFF0055", "0xFFBD00FF"]'::jsonb, true, true),
('cat-drones', 'Drones', 'drones', 'Autonomous camera drones with AI obstacle mapping & LiDAR.', 58684, '["0xFF00F0FF", "0xFF7000FF"]'::jsonb, false, true),
('cat-components', 'Components & Mods', 'components-mods', 'Liquid-cooled neural GPUs, quantum RAM & bespoke chassis.', 58316, '["0xFF0072FF", "0xFF00F5A0"]'::jsonb, false, true),
('cat-accessories', 'Accessories', 'accessories', 'Laser mousepads, magnetic braided cables & gallium chargers.', 57630, '["0xFFFF9900", "0xFFFF007A"]'::jsonb, false, true)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    gradient_colors = EXCLUDED.gradient_colors,
    featured = EXCLUDED.featured,
    is_active = EXCLUDED.is_active;

-- 2. SEED PRODUCTS
INSERT INTO public.products (
    id, sku, name, brand, category, description, price, original_price,
    stock_quantity, low_stock_threshold, warehouse_location, color_stock,
    rating, review_count, imageUrls, tags, specs, colors, is_featured, is_trending
)
VALUES
(
    'prod-01',
    'SKU-NEXUS-PRO-16',
    'NeuralBlade Nexus 16 Pro',
    'CYBERDYNAMICS',
    'Laptops',
    'Quantum-core AI processor with liquid nitrogen cooling chamber and 240Hz dual-frequency micro-LED display. Built for elite cyber-deck operators.',
    289999.00,
    329999.00,
    14,
    4,
    'Bengaluru Central Hub - Bay A-1',
    '{"Matte Obsidian": 6, "Neon Cyan": 5, "Laser Crimson": 3}'::jsonb,
    4.9,
    128,
    '["https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800", "https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=800"]'::jsonb,
    '["Quantum AI", "240Hz", "Liquid Cooled"]'::jsonb,
    '{"CPU": "Neural Core X9", "GPU": "RTX 5090 Mobile 24GB", "RAM": "64GB DDR5 7200MHz", "Storage": "4TB NVMe Gen5"}'::jsonb,
    '["Matte Obsidian", "Neon Cyan", "Laser Crimson"]'::jsonb,
    true,
    true
),
(
    'prod-02',
    'SKU-SYNTH-PULSE-X',
    'SynthPulse Ultra Hologram Phone',
    'AETHER CORP',
    'Smartphones',
    'First consumer smartphone featuring true stereoscopic photonic projection, sapphire ceramic frame, and 300W tachyonic fast charging.',
    124999.00,
    149999.00,
    22,
    5,
    'Bengaluru Central Hub - Bay B-3',
    '{"Cyber Silver": 10, "Electric Purple": 8, "Solar Flare Gold": 4}'::jsonb,
    4.8,
    94,
    '["https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800", "https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=800"]'::jsonb,
    '["Hologram", "300W Charge", "Sapphire Ceramic"]'::jsonb,
    '{"Display": "6.8\" Holographic Micro-OLED", "Chipset": "Aether Quantum 8 Gen 4", "Camera": "200MP Quad Matrix", "Battery": "6000mAh Dual-Cell"}'::jsonb,
    '["Cyber Silver", "Electric Purple", "Solar Flare Gold"]'::jsonb,
    true,
    true
),
(
    'prod-03',
    'SKU-VOID-AUDIO-9',
    'VoidSound ANC Neural Headset',
    'SONIC WAVE',
    'Audio',
    'Audiophile beryllium drivers paired with real-time neural noise cancellation that adapts to ambient audio pulses and brainwave sync.',
    32999.00,
    39999.00,
    38,
    8,
    'Mumbai Fulfillment Center - Bay E-4',
    '{"Midnight Black": 20, "Glitch Green": 12, "Ghost White": 6}'::jsonb,
    4.7,
    215,
    '["https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800", "https://images.unsplash.com/photo-1484704849700-f032a568e944?w=800"]'::jsonb,
    '["Lossless Audio", "Neural ANC", "60hr Battery"]'::jsonb,
    '{"Driver": "50mm Beryllium Matrix", "ANC": "Adaptive Neural 48dB", "Latency": "12ms Ultra-Low", "Weight": "240g"}'::jsonb,
    '["Midnight Black", "Glitch Green", "Ghost White"]'::jsonb,
    false,
    true
),
(
    'prod-04',
    'SKU-CHRONO-CORE-Z',
    'CyberChrono Bio-Holo Smartwatch',
    'CHRONOS LABS',
    'Wearables',
    'Titanium Grade 5 chassis with continuous biometric telemetry, blood glucose laser sensor, and offline military encrypted GPS routing.',
    45999.00,
    52999.00,
    18,
    4,
    'Bengaluru Central Hub - Bay D-2',
    '{"Titanium Raw": 8, "Stealth Carbon": 6, "Neon Orange": 4}'::jsonb,
    4.9,
    88,
    '["https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800"]'::jsonb,
    '["Bio-Telemetry", "Titanium Grade 5", "Offline GPS"]'::jsonb,
    '{"Glass": "Sapphire Crystal 9H", "Water Resistance": "100m Sub-Aqua", "Battery": "14 Days", "Sensors": "ECG + Optical Laser"}'::jsonb,
    '["Titanium Raw", "Stealth Carbon", "Neon Orange"]'::jsonb,
    true,
    false
),
(
    'prod-05',
    'SKU-HYPER-VR-DECK',
    'HyperSight Quantum VR Goggles',
    'IMMERSION DYNAMICS',
    'Gaming & VR',
    'Dual 4K micro-OLED displays with 140-degree field of view, foveated infrared eye tracking, and direct zero-latency wireless display link.',
    89999.00,
    109999.00,
    9,
    3,
    'Bengaluru Central Hub - Bay C-1',
    '{"Matte Obsidian": 6, "Cyber Cyan": 3}'::jsonb,
    4.8,
    64,
    '["https://images.unsplash.com/photo-1622979135225-d2ba269bc1df?w=800"]'::jsonb,
    '["8K Micro-OLED", "Eye Tracking", "Wireless 60GHz"]'::jsonb,
    '{"Resolution": "3840x3840 Per Eye", "Refresh Rate": "144Hz", "FOV": "140 Degrees", "Tracking": "6DoF Inside-Out + Eye"}'::jsonb,
    '["Matte Obsidian", "Cyber Cyan"]'::jsonb,
    false,
    true
),
(
    'prod-06',
    'SKU-AERO-VALKYRIE',
    'Valkyrie Recon 8K Autonomous Drone',
    'SKYNETIK',
    'Drones',
    'Carbon fiber quad-copter with 360-degree LiDAR obstacle matrix, 45-minute flight envelope, and encrypted encrypted dual-band transmission.',
    119999.00,
    139999.00,
    6,
    2,
    'Delhi NCR Warehouse - Bay F-2',
    '{"Stealth Matte": 4, "High-Vis Neon": 2}'::jsonb,
    4.9,
    42,
    '["https://images.unsplash.com/photo-1527977966376-1c8408f9f108?w=800"]'::jsonb,
    '["8K ProRes", "LiDAR Matrix", "45min Flight"]'::jsonb,
    '{"Camera": "1-inch CMOS 8K/60fps", "Range": "15km OcuSync 4", "Speed": "90 km/h", "Wind Resistance": "Level 7"}'::jsonb,
    '["Stealth Matte", "High-Vis Neon"]'::jsonb,
    true,
    false
),
(
    'prod-07',
    'SKU-NEO-QUANTUM-GPU',
    'TitanCore RTX 5090 Liquid Neural GPU',
    'SILICON CORE',
    'Components & Mods',
    'Flagship desktop computing unit with integrated 360mm closed-loop liquid cooler, 32GB GDDR7 memory, and custom RGB acrylic backplate.',
    219999.00,
    249999.00,
    5,
    2,
    'Bengaluru Central Hub - Bay A-3',
    '{"Gunmetal Silver": 3, "Cyberpunk Purple": 2}'::jsonb,
    5.0,
    19,
    '["https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=800"]'::jsonb,
    '["32GB GDDR7", "AIO Liquid Cooled", "DLSS 4"]'::jsonb,
    '{"VRAM": "32GB GDDR7 28Gbps", "Boost Clock": "2.85 GHz", "Cooling": "360mm Radiator + Dual Pump", "TDP": "450W"}'::jsonb,
    '["Gunmetal Silver", "Cyberpunk Purple"]'::jsonb,
    false,
    true
),
(
    'prod-08',
    'SKU-MECH-MATRIX-KB',
    'PulseKey Magnetic Hall-Effect Keyboard',
    'HEXA KEYBOARDS',
    'Accessories',
    'CNC machined 6061 anodized aluminum keyboard with rapid trigger magnetic switches, customizable per-key actuation depth, and hot-swap.',
    16999.00,
    19999.00,
    30,
    6,
    'Bengaluru Central Hub - Bay D-4',
    '{"Space Gray": 14, "Cyber Yellow": 10, "Ice Blue": 6}'::jsonb,
    4.7,
    140,
    '["https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=800"]'::jsonb,
    '["Rapid Trigger", "Hall Effect", "CNC Aluminum"]'::jsonb,
    '{"Switches": "Magnetic Hall 0.1-4.0mm", "Polling Rate": "8000Hz", "Material": "6061 Anodized Aluminum", "RGB": "Underglow + Per-Key"}'::jsonb,
    '["Space Gray", "Cyber Yellow", "Ice Blue"]'::jsonb,
    false,
    false
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    price = EXCLUDED.price,
    stock_quantity = EXCLUDED.stock_quantity,
    description = EXCLUDED.description,
    is_featured = EXCLUDED.is_featured,
    is_trending = EXCLUDED.is_trending;

-- 3. SEED USER PROFILES
INSERT INTO public.user_profiles (id, name, email, phone, role, avatar_url, street, city, state, pincode)
VALUES
('usr_customer_01', 'Aarav Sharma', 'aarav.sharma@cyberpulse.in', '+91 98765 43210', 'customer', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120', 'Flat 402, Cyber Heights, Indiranagar 100ft Road', 'Bengaluru', 'Karnataka', '560038'),
('usr_admin_01', 'Alex Vance', 'admin@cyberpulse.in', '+91 98888 77777', 'admin', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=120', 'CyberPulse Mission Control, Outer Ring Road, Bellandur', 'Bengaluru', 'Karnataka', '560103')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    role = EXCLUDED.role;

-- 4. SEED SAMPLE ORDERS
INSERT INTO public.orders (
    id, customer_name, customer_email, customer_phone, shipping_address,
    items, subtotal, discount, shipping_fee, tax, total, status, payment_method, tracking_number
)
VALUES
(
    'ORD-774921',
    'Aarav Sharma',
    'aarav.sharma@cyberpulse.in',
    '+91 98765 43210',
    'Flat 402, Cyber Heights, Indiranagar 100ft Road, Bengaluru, Karnataka - 560038',
    '[{"product": {"id": "prod-01", "name": "NeuralBlade Nexus 16 Pro", "price": 289999.0, "originalPrice": 329999.0, "imageUrls": ["https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800"]}, "quantity": 1, "selectedColor": "Neon Cyan"}]'::jsonb,
    289999.00,
    2500.00,
    0.00,
    51749.82,
    339248.82,
    'shipped',
    'UPI (Google Pay / PhonePe)',
    'BLR-EXP-99281'
),
(
    'ORD-551029',
    'Aarav Sharma',
    'aarav.sharma@cyberpulse.in',
    '+91 98765 43210',
    'Flat 402, Cyber Heights, Indiranagar 100ft Road, Bengaluru, Karnataka - 560038',
    '[{"product": {"id": "prod-03", "name": "VoidSound ANC Neural Headset", "price": 32999.0, "originalPrice": 39999.0, "imageUrls": ["https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800"]}, "quantity": 1, "selectedColor": "Midnight Black"}]'::jsonb,
    32999.00,
    0.00,
    0.00,
    5939.82,
    38938.82,
    'delivered',
    'RuPay Credit Card',
    'DEL-SPD-44829'
)
ON CONFLICT (id) DO NOTHING;

-- 5. SEED INVENTORY AUDIT LOGS
INSERT INTO public.inventory_logs (
    id, product_id, product_name, sku, type, quantity_changed,
    previous_stock, new_stock, warehouse, note, performed_by
)
VALUES
(
    'LOG-1001',
    'prod-01',
    'NeuralBlade Nexus 16 Pro',
    'SKU-NEXUS-PRO-16',
    'restock',
    10,
    4,
    14,
    'Bengaluru Central Hub - Bay A-1',
    'Q4 Inbound Factory Shipment Received',
    'Automation Bot #4'
),
(
    'LOG-1002',
    'prod-02',
    'SynthPulse Ultra Hologram Phone',
    'SKU-SYNTH-PULSE-X',
    'orderSale',
    -1,
    23,
    22,
    'Bengaluru Central Hub - Bay B-3',
    'Deducted for Order #ORD-774921',
    'System Dispatch'
)
ON CONFLICT (id) DO NOTHING;
