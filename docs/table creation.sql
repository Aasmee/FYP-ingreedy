CREATE TABLE users (
	UID INT AUTO_INCREMENT PRIMARY KEY,
	username VARCHAR(100) NOT NULL UNIQUE,
	email VARCHAR(100) NOT NULL UNIQUE,
	password VARCHAR(100) NOT NULL,
	profile_pic VARCHAR(255) DEFAULT NULL,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
	postID INT AUTO_INCREMENT PRIMARY KEY,
	UID INT,
	caption VARCHAR(255),
	comments_allowed BOOLEAN DEFAULT TRUE,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (UID) REFERENCES users(UID) ON DELETE CASCADE
);

CREATE TABLE post_images (
	id INT AUTO_INCREMENT PRIMARY KEY, 
	post_id INT, 
	image_url VARCHAR(255),
	FOREIGN KEY (post_id) REFERENCES posts(postID) ON DELETE CASCADE
);

CREATE TABLE comments (
	comID INT AUTO_INCREMENT PRIMARY KEY,
	postID INT NOT NULL,
	UID INT NOT NULL,
	content TEXT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (postID) REFERENCES posts(postID) ON DELETE CASCADE,
	FOREIGN KEY (UID) REFERENCES users(UID) ON DELETE CASCADE
);

CREATE TABLE likes (
	likeId INT AUTO_INCREMENT PRIMARY KEY,
	UID INT NOT NULL,
	postID INT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (UID) REFERENCES users(UID) ON DELETE CASCADE,
	FOREIGN KEY (postID) REFERENCES posts(postID) ON DELETE CASCADE,
	UNIQUE (UID, postID)
);

CREATE TABLE bookmarks (
	markID INT AUTO_INCREMENT PRIMARY KEY,
	UID INT NOT NULL,
	postID INT NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (UID) REFERENCES users(UID) ON DELETE CASCADE,
	FOREIGN KEY (postID) REFERENCES posts(postID) ON DELETE CASCADE,
	UNIQUE (UID, postID)
);

CREATE TABLE followers (
	id INT AUTO_INCREMENT PRIMARY KEY,
	follower_user_id INT NOT NULL,
	followed_user_id INT NOT NULL,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (follower_user_id) REFERENCES users(UID) ON DELETE CASCADE,
	FOREIGN KEY (followed_user_id) REFERENCES users(UID) ON DELETE CASCADE,
	UNIQUE (follower_user_id, followed_user_id)
);

CREATE TABLE pantry (
	itemID INT AUTO_INCREMENT PRIMARY KEY,
	UID INT NOT NULL,
	itemName VARCHAR(60) NOT NULL,
    category VARCHAR(80) DEFAULT 'Others',
	quantity DECIMAL(10,2) DEFAULT NULL,
	unit VARCHAR(50) DEFAULT NULL,
	expiryDate DATE DEFAULT NULL,
	createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (UID) REFERENCES users(UID) ON DELETE CASCADE
);


CREATE TABLE ingredients (
	ingreID INT AUTO_INCREMENT PRIMARY KEY, 
	name VARCHAR(60) NOT NULL
);

CREATE TABLE recipes (
	recipeId INT AUTO_INCREMENT PRIMARY KEY,
	recipeName VARCHAR(255) NOT NULL,
	description TEXT,
	image_url VARCHAR(255)
);

DROP TABLE recipe_ingredients;

CREATE TABLE recipe_ingredients (
	ID INT AUTO_INCREMENT PRIMARY KEY,
	ingredientName VARCHAR(50) NOT NULL,
	recipeId INT NOT NULL,
	quantity VARCHAR(50),
	unit VARCHAR(50),
	FOREIGN KEY (recipeId) REFERENCES recipes(recipeId) ON DELETE CASCADE
);


CREATE TABLE recipe_steps (
	stepId INT AUTO_INCREMENT PRIMARY KEY,
	recipeId INT NOT NULL,
	stepNumber INT NOT NULL,
	stepDescription TEXT NOT NULL,
	FOREIGN KEY (recipeId) REFERENCES recipes(recipeId) ON DELETE CASCADE
);

CREATE TABLE saved_recipes (
	id INT AUTO_INCREMENT PRIMARY KEY,
	recipeId INT NOT NULL,
	UID INT NOT NULL,
	savedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (recipeId) REFERENCES recipes(recipeId) ON DELETE CASCADE,
	FOREIGN KEY (UID) REFERENCES users(UID) ON DELETE CASCADE,
	UNIQUE (UID, recipeId)
);

CREATE TABLE tags (
	tagID INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE recipe_tags (
	id INT AUTO_INCREMENT PRIMARY KEY,
	recipeID INT NOT NULL,
	tagID INT NOT NULL,
	FOREIGN KEY (recipeID) REFERENCES recipes(recipeId) ON DELETE CASCADE,
	FOREIGN KEY (tagID) REFERENCES tags(tagID) ON DELETE CASCADE,
	UNIQUE (recipeID, tagID)
);

CREATE TABLE search_history (
	historyID INT AUTO_INCREMENT PRIMARY KEY,
	UID INT NOT NULL,
	search_query VARCHAR(255),
	applied_tags TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (UID) REFERENCES users(UID) ON DELETE CASCADE
);

CREATE TABLE recipe_views (
	viewID INT AUTO_INCREMENT PRIMARY KEY,
	UID INT NOT NULL,
	recipeID INT NOT NULL,
	viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (UID) REFERENCES users(UID) ON DELETE CASCADE,
	FOREIGN KEY (recipeID) REFERENCES recipes(recipeID) ON DELETE CASCADE
);

INSERT INTO ingredients (ingreID, name) VALUES
(1, 'Spaghetti'),
(2, 'Ground Beef'),
(3, 'Onion'),
(4, 'Tomato'),
(5, 'Potato'),
(6, 'Egg'),
(7, 'Rice'),
(8, 'Garlic'),
(9, 'Salt'),
(10, 'Cooking Oil'),
(11, 'Olive Oil'),
(12, 'Sesame Oil'),
(13, 'Avocado Oil'),
(14, 'Perilla Oil'),
(15, 'Flour'),
(16, 'Sugar'),
(17, 'Milk'),
(18, 'Egg Whites'),
(19, 'Egg Yolks'),
(20, 'Heavy Cream'),
(21, 'Cheese'),
(22, 'Mozarella Cheese'),
(23, 'Tomato Sauce'),
(24, 'Soy Sauce'),
(25, 'Fresh Mozarella'),
(26, 'Cream Cheese'),
(27, 'Cheddar Cheese'),
(28, 'Cheese Curds'),
(29, 'Yogurt'),
(30, 'Parmesan Cheese'),
(31, 'Gruyère Cheese'),
(32, 'Condensed Milk'),
(33, 'Butter Milk'),
(34, 'Ice Cream'),
(35, 'Butter'),
(36, 'Sour Cream'),
(37, 'Mayonnaise'),
(38, 'Yeast'),
(39, 'Tofu'),
(40, 'Carrot'),
(41, 'Lettuce'),
(42, 'Cabbage'),
(43, 'Ginger'),
(44, 'Cucumber'),
(45, 'Zucchini'),
(46, 'Spinach'),
(47, 'Eggplant'),
(48, 'Pickles'),
(49, 'Lady Fingers'),
(50, 'Bell Pepper'),
(51, 'Chilli'),
(52, 'Scallions'),
(53, 'Avocado'),
(54, 'Mushroom'),
(55, 'Berry'),
(56, 'Banana'),
(57, 'Cilantro'),
(58, 'Pork'),
(59, 'Chicken'),
(60, 'Beef'),
(61, 'Mutton'),
(62, 'Shrimp'),
(63, 'Clams'),
(64, 'Oyster'),
(65, 'Abalone'),
(66, 'Squid'),
(67, 'Octopus'),
(68, 'Vinegar'),
(69, 'Sausage'),
(70, 'Bacon'),
(71, 'Ground Pork'),
(72, 'Chicken Thighs'),
(73, 'Chicken Breats'),
(74, 'Chicken Feet'),
(75, 'Chicken Glizzards'),
(76, 'Chicken Wings'),
(77, 'Kimchi'),
(78, 'Pickled Vegetables'),
(79, 'Gochujang'),
(80, 'Sweet Soy Sauce'),
(81, 'Fish Sauce'),
(82, 'Rice Vinegar'),
(83, 'Balsamic Vinegar'),
(84, 'Hot Sauce'),
(85, 'Seaweed Sheets'),
(86, 'Imitation Crab'),
(87, 'Dumpling Wrappers'),
(88, 'Pork Belly'),
(89, 'Ground Pork'),
(90, 'Egg Noodles'),
(91, 'Noodles'),
(92, 'Ramen Noodles'),
(93, 'Ham'),
(94, 'Roast Pork'),
(95, 'Mustard'),
(96, 'Vanilla Extract'),
(97, 'Dark Chocolate'),
(98, 'Brown Sugar'),
(99, 'Gelatin'),
(100, 'Cocoa Powder'),
(101, 'Graham Crackers'),
(102, 'Pastry Dough'),
(103, 'Espresso'),
(104, 'Swiss Cheese'),
(105, 'Cuban Cheese'),
(106, 'Mascarpone Cheese'),
(107, 'Tortilla'),
(108, 'Paprika'),
(109, 'Peppers'),
(110, 'Peanuts'),
(111, 'Lime juice'),
(112, 'Cumin'),
(113, 'Pork Chop'),
(114, 'Panko Breadcrumbs'),
(115, 'Strawberry Sauce'),
(116, 'Rice Noodles'),
(117, 'Salmon'),
(118, 'Tomato Puree'),
(119, 'Cajun Seasoning'),
(120, 'Seafood Mix'),
(121, 'Sushi Rice'),
(122, 'Cinnamon'),
(123, 'Herbs'),
(124, 'Coconut Milk'),
(125, 'Curry Paste'),
(126, 'Bulgur Wheat'),
(127, 'Bleck Beans'),
(128, 'Hominy'),
(129, 'Jalapenos'),
(130, 'Rye Flour'),
(131, 'Shallots'),
(132, 'Bay Leaves'),
(133, 'Turmeric'),
(134, 'Chilli Paste'),
(135, 'Chilli Powder'),
(136, 'Garam Masala'),
(137, 'Pear'),
(138, 'Cauliflower'),
(139, 'Chickpeas'),
(140, 'Lemon Grass'),
(141, 'Beef Short Ribs'),
(142, 'Chipotle Peppers'),
(143, 'Sichuan Peppercorn'),
(144, 'Cornmeal'),
(145, 'Rice Cake'),
(146, 'Fish Cake'),
(147, 'Phyllo Dough'),
(148, 'Doubanjiang'),
(149, 'Feta Cheese'),
(150, 'Cinnamon Stick'),
(151, 'Star Anise'),
(152, 'Parsley'),
(153, 'Basil'),
(154, 'Saffron'),
(155, 'Pita Bread'),
(156, 'Celery'),
(157, 'Red Bell Pepper'),
(158, 'Galangal'),
(159, 'Kaffir Lime Leaves'),
(160, 'Kidney Beans'),
(161, 'Glutinous Rice Flour'),
(162, 'Lentils'),
(163, 'Beef Broth'),
(164, 'Tzatziki Sauce'),
(165, 'Fettuccine Pasta'),
(166, 'Wakame Seaweed'),
(167, 'Miso Paste'),
(168, 'Dashi Stock'),
(169, 'Curry Powder'),
(170, 'Gravy'),
(171, 'Basmati Rice'),
(172, 'Beef Bones'),
(173, 'Tapioca Flour'),
(174, 'Corn Husks'),
(175, 'Masa Harina'),
(176, 'Chilli Sauce'),
(177, 'Bread'),
(178, 'Baguette'),
(179, 'Laksa Paste'),
(180, 'Berbere Spice'),
(181, 'Red Wine'),
(182, 'Tonkatsu Sauce'),
(183, 'White Fish'),
(184, 'Corn Tortilla'),
(185, 'Prok Cutlet'),
(186, 'White Wine'),
(187, 'Honey'),
(189, 'Paneer'),
(190, 'Bonito Flakes'),
(191, 'Hollandaise Sauce'),
(192, 'Oats'),
(193, 'Poached Eggs'),
(194, 'Hoisin Sauce'),
(195, 'English Muffins'),
(196, 'Veal Shanks'),
(197, 'Puff Pastry'),
(198, 'Duck'),
(199, 'Beef Tenderloin'),
(200, 'Cornstarch'),
(201, 'Pie Crust'),
(202, 'Almonds'),
(203, 'Pistachio'),
(204, 'Walnuts'),
(205, 'Béchamel Sauce');