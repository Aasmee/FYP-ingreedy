const express = require('express');
const router = express.Router();
const { pool } = require('../db/db');

// Get All Recipes (Basic info only)
router.get('/', async (req, res) => {
    try {
        const [recipes] = await pool.execute(
            "SELECT recipeId, recipeName, description, image_url FROM recipes ORDER BY recipeName ASC"
        );
        res.json({ success: true, recipes });
    } catch (error) {
        console.error('Error fetching recipes:', error);
        res.status(500).json({ success: false, message: "Server error" });
    }
});

// Search Recipes by Name
router.get('/search', async (req, res) => {
    const searchTerm = `%${req.query.q}%`;
    try {
        const [recipes] = await pool.execute(
            `SELECT DISTINCT r.recipeId, r.recipeName, r.description, r.image_url 
             FROM recipes r
             LEFT JOIN recipe_ingredients ri ON r.recipeId = ri.recipeId
             WHERE r.recipeName LIKE ? OR ri.ingredientName LIKE ?`, 
            [searchTerm, searchTerm]
        );
        res.json({ success: true, recipes });
    } catch (error) {
        console.error('Error searching recipes:', error);
        res.status(500).json({ success: false, message: "Server error" });
    }
});

// Get Recipe Details by ID
router.get('/:id', async (req, res) => {
    const recipeId = req.params.id;
    try {
        const [recipe] = await pool.execute(
            "SELECT * FROM recipes WHERE recipeId = ?", 
            [recipeId]
        );
        
        if (recipe.length === 0) {
            return res.status(404).json({ success: false, message: "Recipe not found" });
        }
        
        const [ingredients] = await pool.execute(
            "SELECT * FROM recipe_ingredients WHERE recipeId = ?", 
            [recipeId]
        );
        
        const [steps] = await pool.execute(
            "SELECT * FROM recipe_steps WHERE recipeId = ? ORDER BY stepNumber", 
            [recipeId]
        );

        res.json({ success: true, recipe: recipe[0], ingredients, steps });
    } catch (error) {
        console.error('Error fetching recipe details:', error);
        res.status(500).json({ success: false, message: "Server error" });
    }
});

module.exports = router;
