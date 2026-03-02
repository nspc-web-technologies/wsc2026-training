-- phpMyAdmin SQL Dump
-- version 5.2.1deb3
-- https://www.phpmyadmin.net/
--
-- ホスト: localhost:3306
-- 生成日時: 2026 年 2 月 24 日 00:55
-- サーバのバージョン： 10.11.13-MariaDB-0ubuntu0.24.04.1
-- PHP のバージョン: 8.4.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- データベース: `db_m2`
--

-- --------------------------------------------------------

--
-- テーブルの構造 `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- テーブルの構造 `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- テーブルの構造 `companies`
--

CREATE TABLE `companies` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `company_name` varchar(255) NOT NULL,
  `company_address` text NOT NULL,
  `company_telephone_number` varchar(50) NOT NULL,
  `company_email_address` varchar(50) NOT NULL,
  `owner_name` varchar(255) NOT NULL,
  `owner_mobile_number` varchar(50) NOT NULL,
  `owner_email_address` varchar(255) NOT NULL,
  `contact_name` varchar(255) NOT NULL,
  `contact_mobile_number` varchar(50) NOT NULL,
  `contact_email_address` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- テーブルのデータのダンプ `companies`
--

INSERT INTO `companies` (`id`, `company_name`, `company_address`, `company_telephone_number`, `company_email_address`, `owner_name`, `owner_mobile_number`, `owner_email_address`, `contact_name`, `contact_mobile_number`, `contact_email_address`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Innovateurs Tech SARL', '123 Boulevard du Silicon 75001 Paris', '+33 1 23 45 67 89', 'info@innovateurstech.fr', 'Alice Dupont', '+33 6 12 34 56 78', 'alice.dupont@innovateurstech.fr', 'Bob Martin', '+33 6 98 76 54 32', 'bob.martin@innovateurstech.fr', 0, NULL, '2026-02-18 20:01:21'),
(2, 'Solutions Vertes SAS', '456 Parc Éco 69002 Lyon', '+33 4 56 78 90 12', 'contact@solutionsvertes.fr', 'Sarah Lefevre', '+33 6 23 45 67 89', 'sarah.lefevre@solutionsvertes.fr', 'Tom Dubois', '+33 6 87 65 43 21', 'tom.dubois@solutionsvertes.fr', 0, NULL, '2026-02-23 00:35:11'),
(3, 'Designs Urbains SARL', '789 Avenue Métropolitaine 13001 Marseille', '+33 4 12 34 56 78', 'support@designsurbains.fr', 'Michael Petit', '+33 6 34 56 78 90', 'michael.petit@designsurbains.fr', 'Emily Moreau', '+33 6 54 32 10 98', 'emily.moreau@designsurbains.fr', 1, NULL, NULL),
(4, 'Cuisine Innovante SARL', '22 Rue de la Cuisine 75005 Paris', '+33 1 40 20 30 40', 'info@cuisineinnovante.fr', 'Jean Martin', '+33 6 11 22 33 44', 'jean.martin@cuisineinnovante.fr', 'Chloe Dubois', '+33 6 55 44 33 22', 'chloe.dubois@cuisineinnovante.fr', 1, NULL, NULL),
(5, 'Énergies Renouvelables SAS', '15 Chemin Vert 31000 Toulouse', '+33 5 61 23 45 67', 'contact@energiesrenouvelables.fr', 'Louise Garnier', '+33 6 77 88 99 00', 'louise.garnier@energiesrenouvelables.fr', 'Paul Leroy', '+33 6 66 77 88 99', 'paul.leroy@energiesrenouvelables.fr', 1, NULL, NULL),
(6, 'Technologie Avancée SARL', '9 Rue de la Science 59800 Lille', '+33 3 20 15 25 35', 'support@technologieavancee.fr', 'Luc Bernard', '+33 6 33 44 55 66', 'luc.bernard@technologieavancee.fr', 'Isabelle Thomas', '+33 6 44 55 66 77', 'isabelle.thomas@technologieavancee.fr', 1, NULL, NULL),
(7, 'Artisanat Moderne SAS', '28 Avenue de l\'Artisanat 67000 Strasbourg', '+33 3 88 10 20 30', 'info@artisanatmoderne.fr', 'Emma Morel', '+33 6 22 33 44 55', 'emma.morel@artisanatmoderne.fr', 'Julien Rousseau', '+33 6 77 66 55 44', 'julien.rousseau@artisanatmoderne.fr', 1, NULL, NULL),
(8, 'セイコーエプソン', '長野', '+33 1 23 45 67 89', 'info@innovateurstech.fr', '𠮷田さん', '+33 6 12 34 56 78', 'alice.dupont@innovateurstech.fr', 'Bob Martin', '+33 6 98 76 54 32', 'bob.martin@innovateurstech.fr', 1, '2026-02-23 00:34:56', '2026-02-23 00:34:56');

-- --------------------------------------------------------

--
-- テーブルの構造 `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- テーブルのデータのダンプ `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_sessions_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '2026_02_17_053544_create_companies_table', 1),
(4, '2026_02_17_054939_create_products_table', 1);

-- --------------------------------------------------------

--
-- テーブルの構造 `products`
--

CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `gtin` varchar(14) NOT NULL,
  `name` varchar(255) NOT NULL,
  `name_in_french` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `description_in_french` text NOT NULL,
  `brand_name` varchar(255) NOT NULL,
  `country_of_origin` varchar(255) NOT NULL,
  `gross_weight_with_packaging` decimal(10,3) NOT NULL,
  `net_content_weight` decimal(10,3) NOT NULL,
  `weight_unit` varchar(10) NOT NULL,
  `image_path` varchar(512) DEFAULT NULL,
  `is_hidden` tinyint(1) NOT NULL DEFAULT 0,
  `company_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- テーブルのデータのダンプ `products`
--

INSERT INTO `products` (`id`, `gtin`, `name`, `name_in_french`, `description`, `description_in_french`, `brand_name`, `country_of_origin`, `gross_weight_with_packaging`, `net_content_weight`, `weight_unit`, `image_path`, `is_hidden`, `company_id`, `created_at`, `updated_at`) VALUES
(1, '37900123458228', 'French Herb and Lemon Infused Olive Oil', 'Huile d\'olive infusée aux herbes et au citron français', 'Add a touch of freshness to your dishes with our French herb and lemon infused olive oil, featuring a blend of fragrant herbs and citrus.', 'Ajoutez une touche de fraîcheur à vos plats avec notre huile d\'olive infusée aux herbes françaises et au citron, composée d\'un mélange d\'herbes parfumées et d\'agrumes.', 'Huiles de France', 'France', 0.500, 0.400, 'g', NULL, 0, 1, NULL, NULL),
(2, '37900123458345', 'Artisanal French Quiche Lorraine Tartlets', 'Tartelettes de quiche lorraine artisanale française', 'Indulge in the rich flavors of France with our artisanal quiche Lorraine tartlets, featuring a blend of creamy eggs and cheese.', 'Laissez-vous tenter par les riches saveurs de la France avec nos tartelettes artisanales à la quiche lorraine, composées d\'un mélange d\'œufs crémeux et de fromage.', 'Pâtisseries Artisanales', 'France', 1.200, 0.800, 'g', NULL, 0, 1, NULL, NULL),
(3, '37900123458462', 'French Lavender and Honey Body Scrub', 'Exfoliant corporel à la lavande et au miel français', 'Exfoliate your skin with our French lavender and honey body scrub, featuring a soothing blend of fragrant herbs and citrus.', 'Exfoliez votre peau avec notre gommage corporel à la lavande française et au miel, composé d\'un mélange apaisant d\'herbes parfumées et d\'agrumes.', 'Soins Corporels de France', 'France', 0.600, 0.500, 'g', NULL, 0, 1, NULL, NULL),
(4, '37900123458579', 'French Apple and Cinnamon Crumble Mix', 'Mélange de crumble aux pommes et au cannelle français', 'Warm up with our French apple and cinnamon crumble mix, featuring a blend of fresh spices perfect for a comforting dessert.', 'Réchauffez-vous avec notre mélange de crumble aux pommes et à la cannelle française, composé d\'un mélange d\'épices fraîches, parfait pour un dessert réconfortant.', 'Dessertès de France', 'France', 0.800, 0.600, 'g', NULL, 0, 1, NULL, NULL),
(5, '37900123458696', 'Artisanal French Creamy Garlic Dip', 'Mélange de dip aux aromes et à la crème française', 'Savor the rich flavors of France with our artisanal creamy garlic dip, featuring a blend of fresh herbs and spices.', 'Savourez les riches saveurs de la France avec notre trempette crémeuse à l\'ail artisanale, composée d\'un mélange d\'herbes fraîches et d\'épices.', 'Fromages Artisanales', 'France', 0.600, 0.500, 'g', NULL, 0, 1, NULL, NULL),
(6, '37900123458713', 'French Berry Jam', 'Confiture de fruits rouges français', 'Enjoy the sweetness of France with our French berry jam, featuring a blend of juicy fruits.', 'Appréciez la douceur de la France avec notre confiture de baies françaises, composée d\'un mélange de fruits juteux.', 'Jams de France', 'France', 0.700, 0.550, 'g', NULL, 0, 1, NULL, NULL),
(7, '37900123458830', 'Artisanal French Feta Cheese', 'Fromage feta artisanale français', 'Savor the rich flavors of Greece in France with our artisanal feta cheese, featuring a blend of creamy milk and herbs.', 'Savourez les riches saveurs de la Grèce en France avec notre fromage feta artisanal, composé d\'un mélange de lait crémeux et d\'herbes.', 'Fromages Artisanales', 'France', 1.000, 0.850, 'g', NULL, 0, 1, NULL, NULL),
(8, '37900123458947', 'French Herb and Garlic Sausages', 'Saucisses aux herbes et à l\'ail français', 'Indulge in the rich flavors of France with our French herb and garlic sausages, featuring a blend of fragrant herbs and spices.', 'Laissez-vous tenter par les riches saveurs de la France avec nos saucisses françaises aux herbes et à l\'ail, composées d\'un mélange d\'herbes parfumées et d\'épices.', 'Charcuterie de France', 'France', 1.200, 0.900, 'g', NULL, 0, 1, NULL, NULL),
(9, '37900123459064', 'French Apple Tart', 'Tarte tatin aux pommes française', 'Enjoy the sweetness of France with our French apple tart, featuring a blend of juicy fruits and creamy pastry.', 'Savourez la douceur de la France avec notre tarte aux pommes française, composée d\'un mélange de fruits juteux et de pâtisserie crémeuse.', 'Pâtisseries Artisanales', 'France', 1.000, 0.850, 'g', NULL, 0, 1, NULL, NULL),
(10, '37900123459171', 'Artisanal French Cream Cheese', 'Fromage à la crème artisanale français', 'Savor the rich flavors of France with our artisanal cream cheese, featuring a blend of creamy milk and herbs.', 'Savourez les riches saveurs de la France avec notre fromage à la crème artisanal, composé d\'un mélange de lait crémeux et d\'herbes.', 'Fromages Artisanales', 'France', 0.600, 0.500, 'g', NULL, 0, 1, NULL, NULL),
(11, '37900123459288', 'French Herb and Lemon Marmalade', 'Marmelade aux herbes et au citron français', 'Enjoy the sweetness of France with our French herb and lemon marmalade, featuring a blend of fragrant herbs and citrus.', 'Savourez la douceur de la France avec notre marmelade d\'herbes et de citron française, composée d\'un mélange d\'herbes parfumées et d\'agrumes.', 'Jams de France', 'France', 0.700, 0.550, 'g', NULL, 0, 1, NULL, NULL),
(12, '37900123459395', 'Artisanal French Goat Cheese', 'Fromage chèvre artisanale français', 'Savor the rich flavors of France with our artisanal goat cheese, featuring a blend of creamy milk and herbs.', 'Savourez les riches saveurs de la France avec notre fromage de chèvre artisanal, composé d\'un mélange de lait crémeux et d\'herbes.', 'Fromages Artisanales', 'France', 1.000, 0.850, 'g', NULL, 0, 1, NULL, '2026-02-23 00:36:51'),
(13, '37900123459412', 'French Apple Cider', 'Cidre aux pommes français', 'Enjoy the sweetness of France with our French apple cider, featuring a blend of juicy fruits and spices.', 'Savourez la douceur de la France avec notre cidre de pomme français, composé d\'un mélange de fruits juteux et d\'épices.', 'Bieres de France', 'France', 0.800, 0.600, 'g', NULL, 0, 1, NULL, NULL),
(14, '37900123459529', 'Artisanal French Creamy Cheese Dip', 'Mélange de dip à la crème française', 'Savor the rich flavors of France with our artisanal creamy cheese dip, featuring a blend of fresh herbs and spices.', 'Savourez les riches saveurs de la France avec notre trempette au fromage crémeuse artisanale, composée d\'un mélange d\'herbes fraîches et d\'épices.', 'Fromages Artisanales', 'France', 0.600, 0.500, 'g', NULL, 0, 1, NULL, NULL),
(15, '37900123459646', 'French Herb and Garlic Sauce', 'Sauce aux herbes et à l\'ail française', 'Enjoy the richness of France with our French herb and garlic sauce, featuring a blend of fragrant herbs and spices.', 'Savourez la richesse de la France avec notre sauce aux herbes et à l\'ail française, composée d\'un mélange d\'herbes parfumées et d\'épices.', 'Charcuterie de France', 'France', 1.000, 0.850, 'g', NULL, 0, 1, NULL, NULL),
(16, '37900123459763', 'Artisanal French Cream Cheese Spread', 'Fromage à la crème artisanale française pour tartiner', 'Savor the rich flavors of France with our artisanal cream cheese spread, featuring a blend of creamy milk and herbs.', 'Savourez les riches saveurs de la France avec notre tartinade de fromage à la crème artisanale, composée d\'un mélange de lait crémeux et d\'herbes.', 'Fromages Artisanales', 'France', 0.600, 0.500, 'g', NULL, 0, 1, NULL, NULL),
(17, '37900123459870', 'French Apple Compote', 'Compote de pommes française', 'Enjoy the sweetness of France with our French apple compote, featuring a blend of juicy fruits and spices.', 'Savourez la douceur de la France avec notre compote de pommes française, composée d\'un mélange de fruits juteux et d\'épices.', 'Dessertès de France', 'France', 0.700, 0.550, 'g', NULL, 0, 1, NULL, NULL),
(18, '37900234567890', 'Eco-Friendly Reusable Water Bottle', 'Bouteille d\'eau réutilisable et écologique', 'Stay hydrated and reduce plastic waste with our eco-friendly reusable water bottle, featuring a BPA-free design.', 'Restez hydraté et réduisez les déchets plastiques avec notre bouteille d\'eau réutilisable respectueuse de l\'environnement, dotée d\'une conception sans BPA.', 'HydroFlow', 'USA', 0.300, 0.200, 'g', NULL, 0, 1, NULL, NULL),
(19, '37900234567907', 'Artisanal Handmade Soap Set', 'Ensemble de savons artisanaux faits à la main', 'Nourish your skin with our artisanal handmade soap set, featuring a blend of natural ingredients and essential oils.', 'Nourrissez votre peau avec notre ensemble de savons artisanaux faits à la main, contenant un mélange d\'ingrédients naturels et d\'huiles essentielles.', 'Purezza', 'Italy', 0.600, 0.500, 'g', NULL, 0, 1, NULL, NULL),
(20, '37900234568024', 'French Luxury Candles Set', 'Ensemble de bougies de luxe françaises', 'Illuminate your space with our French luxury candles set, featuring a collection of scented candles in elegant packaging.', 'Illuminez votre espace avec notre coffret de bougies de luxe françaises, comprenant une collection de bougies parfumées dans un emballage élégant.', 'Cierges de France', 'France', 1.000, 0.850, 'g', NULL, 0, 1, NULL, NULL),
(21, '37900234568141', 'Eco-Friendly Bamboo Toothbrush Set', 'Ensemble de brosses à dents en bambou écologiques', 'Brush your teeth and reduce waste with our eco-friendly bamboo toothbrush set, featuring a set of biodegradable toothbrushes and replaceable heads.', 'Brossez-vous les dents et réduisez les déchets avec notre ensemble de brosses à dents en bambou respectueux de l\'environnement, comprenant un ensemble de brosses à dents biodégradables et des têtes remplaçables.', 'Teeth & Smile', 'Indonesia', 0.200, 0.100, 'g', NULL, 0, 1, NULL, NULL),
(22, '37900234568258', 'Artisanal Handmade Jewelry Box', 'Coffret à bijoux artisanal fait à la main', 'Store your treasured jewelry in style with our artisanal handmade jewelry box, featuring a beautifully crafted wooden design.', 'Rangez vos précieux bijoux avec style grâce à notre boîte à bijoux artisanale faite à la main, dotée d\'un design en bois magnifiquement conçu.', 'JewelBox', 'Mexico', 0.500, 0.400, 'g', NULL, 0, 1, NULL, NULL),
(23, '37900234568375', 'Luxury Essential Oil Diffuser', 'Diffuseur d\'huiles essentielles de luxe', 'Pamper yourself with the scent of luxury essential oils using our luxury essential oil diffuser, featuring a stylish and modern design.', 'Faites-vous plaisir avec le parfum des huiles essentielles de luxe en utilisant notre diffuseur d\'huiles essentielles de luxe, doté d\'un design élégant et moderne.', 'Aromaflo', 'Australia', 1.000, 0.850, 'g', NULL, 0, 1, NULL, NULL),
(24, '37900234568492', 'Eco-Friendly Reusable Shopping Bag Set', 'Ensemble de sacs de courses réutilisables et écologiques', 'Reduce plastic waste and go green with our eco-friendly reusable shopping bag set, featuring a set of durable cotton bags and recycled material handles.', 'Réduisez les déchets plastiques et passez au vert avec notre ensemble de sacs de courses réutilisables respectueux de l\'environnement, comprenant un ensemble de sacs en coton durables et des poignées en matériaux recyclés.', 'GreenEarth', 'UK', 0.500, 0.400, 'g', NULL, 0, 1, NULL, NULL),
(25, '37900234568509', 'Artisanal Handmade Home Fragrance Spray', 'Spray de parfum d\'ambiance artisanal fait à la main', 'Freshen up your home with our artisanal handmade home fragrance spray, featuring a blend of natural ingredients and essential oils.', 'Rafraîchissez votre maison avec notre spray parfumé d\'intérieur artisanal fait à la main, contenant un mélange d\'ingrédients naturels et d\'huiles essentielles.', 'Purezza', 'Italy', 0.200, 0.100, 'g', NULL, 0, 1, NULL, NULL),
(26, '37900234568626', 'French Luxury Aromatherapy Set', 'Ensemble d\'aromathérapie de luxe français', 'Pamper yourself with the scent of luxury aromatherapy using our French luxury aromatherapy set, featuring a collection of scented candles and essential oils.', 'Faites-vous plaisir avec le parfum de l\'aromathérapie de luxe grâce à notre coffret d\'aromathérapie de luxe français, comprenant une collection de bougies parfumées et d\'huiles essentielles.', 'Cierges de France', 'France', 1.000, 0.850, 'g', NULL, 0, 1, NULL, NULL),
(27, '37900234568733', 'Eco-Friendly Reusable Lunch Box Set', 'Ensemble de boîtes à lunch réutilisables et écologiques', 'Pack your lunch in style and reduce waste with our eco-friendly reusable lunch box set, featuring a set of durable cotton bags and recycled material handles.', 'Emballez votre déjeuner avec style et réduisez les déchets grâce à notre coffret à lunch réutilisable respectueux de l\'environnement, comprenant un ensemble de sacs en coton durables et des poignées en matériaux recyclés.', 'GreenEarth', 'UK', 0.500, 0.400, 'g', NULL, 0, 1, NULL, NULL),
(28, '37900234568850', 'Artisanal Handmade Stationery Set', 'Ensemble de papeterie artisanale faite à la main', 'Stay organized and creative with our artisanal handmade stationery set, featuring a collection of handmade notebooks, pens, and pencils.', 'Restez organisé et créatif avec notre ensemble de papeterie artisanale faite à la main, comprenant une collection de cahiers, de stylos et de crayons faits à la main.', 'PaperCraft', 'USA', 0.300, 0.200, 'g', NULL, 0, 1, NULL, NULL),
(29, '37900234568967', 'Luxury Wall Art Print Set', 'Ensemble d\'impressions murales de luxe', 'Add some style to your walls with our luxury wall art print set, featuring a collection of high-quality prints from around the world.', 'Ajoutez du style à vos murs avec notre ensemble d\'impressions murales de luxe, comprenant une collection d\'impressions de haute qualité du monde entier.', 'ArtScene', 'Canada', 1.000, 0.850, 'g', NULL, 0, 1, NULL, NULL),
(30, '37900234569084', 'Eco-Friendly Reusable Phone Case Set', 'Ensemble de coques de téléphone réutilisables et écologiques', 'Protect your phone and reduce waste with our eco-friendly reusable phone case set, featuring a set of durable cotton cases and recycled material inserts.', 'Protégez votre téléphone et réduisez les déchets avec notre ensemble de coques de téléphone réutilisables respectueuses de l\'environnement, comprenant un ensemble de coques en coton durables et d\'inserts en matériaux recyclés.', 'GreenEarth', 'UK', 0.500, 0.400, 'g', NULL, 0, 1, NULL, NULL),
(31, '37900234569101', 'Artisanal Handmade Bookmarks Set', 'Ensemble de marque-pages artisanaux faits à la main', 'Mark your favorite pages in style with our artisanal handmade bookmarks set, featuring a collection of handmade bookmarks and book lights.', 'Marquez vos pages préférées avec style avec notre ensemble de marque-pages artisanaux faits à la main, comprenant une collection de marque-pages et de lampes de lecture faits à la main.', 'PageTurner', 'Mexico', 0.200, 0.100, 'g', NULL, 0, 1, NULL, NULL),
(32, '37900234569218', 'French Luxury Desk Accessory Set', 'Ensemble d\'accessoires de bureau de luxe français', 'Elevate your workspace with our French luxury desk accessory set, featuring a collection of scented candles, essential oils, and handmade stationery.', 'Améliorez votre espace de travail avec notre ensemble d\'accessoires de bureau de luxe français, comprenant une collection de bougies parfumées, d\'huiles essentielles et de papeterie faite à la main.', 'Cierges de France', 'France', 1.000, 0.850, 'g', NULL, 0, 1, NULL, NULL),
(33, '37900234569335', 'Eco-Friendly Reusable Travel Bag Set', 'Ensemble de sacs de voyage réutilisables et écologiques', 'Travel in style and reduce waste with our eco-friendly reusable travel bag set, featuring a set of durable cotton bags and recycled material handles.', 'Voyagez avec style et réduisez les déchets avec notre ensemble de sacs de voyage réutilisables respectueux de l\'environnement, comprenant un ensemble de sacs en coton durables et de poignées en matériaux recyclés.', 'GreenEarth', 'UK', 0.500, 0.400, 'g', NULL, 0, 1, NULL, NULL),
(34, '37900234569452', 'Artisanal Handmade Wall Hanging Set', 'Ensemble de tentures murales artisanales faites à la main', 'Add some handmade charm to your walls with our artisanal handmade wall hanging set, featuring a collection of hand-painted ceramics and natural fibers.', 'Ajoutez un peu de charme artisanal à vos murs avec notre ensemble de tentures murales artisanales faites à la main, comprenant une collection de céramiques peintes à la main et de fibres naturelles.', 'WallDecor', 'Italy', 1.000, 0.850, 'g', NULL, 0, 1, NULL, NULL),
(52, '39900123458228', 'fdghdfghdfgh', 'dfghdfgh', 'dfghdfghdfgh', 'fhgdfghdfghdfg', 'hdfgfdghdfgh', 'hdfghdfgh', 5757.000, 567576.000, 'kg', 'products/39900123458228.jpg', 0, 8, '2026-02-19 23:27:29', '2026-02-23 01:11:15');

-- --------------------------------------------------------

--
-- テーブルの構造 `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- テーブルのデータのダンプ `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('lvSA3C4dSW2kFg1iHk9aSgO2aRsYCszop4KDtUe9', NULL, '10.0.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoiTGdTS2ZtRzlLcXV5S2xSRks4ZVBsWGZ5cFZHd2c4TGxvTmlGRlljciI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzk6Imh0dHA6Ly9sb2NhbGhvc3Q6ODA4Mi8xN19tb2R1bGVfYi9sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6MTA6InBhc3NwaHJhc2UiO3M6NToiYWRtaW4iO30=', 1771894475);

--
-- ダンプしたテーブルのインデックス
--

--
-- テーブルのインデックス `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- テーブルのインデックス `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- テーブルのインデックス `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`id`);

--
-- テーブルのインデックス `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- テーブルのインデックス `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `products_gtin_unique` (`gtin`),
  ADD KEY `products_company_id_foreign` (`company_id`);

--
-- テーブルのインデックス `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- ダンプしたテーブルの AUTO_INCREMENT
--

--
-- テーブルの AUTO_INCREMENT `companies`
--
ALTER TABLE `companies`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- テーブルの AUTO_INCREMENT `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- テーブルの AUTO_INCREMENT `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- ダンプしたテーブルの制約
--

--
-- テーブルの制約 `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_company_id_foreign` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
