/**
 * @swagger
 * components:
 *   schemas:
 *     Categories:
 *       type: object
 *       required:
 *         - Name
 *       properties:
 *         Id:
 *           type: string
 *           description: The unique identifier of the category
 *         Name:
 *           type: string
 *           description: The name of the category
 *         CrtAt:
 *           type: string
 *           format: date-time
 *           description: The date and time when the category was created
 *         CrtBy:
 *           type: string
 *           description: The creator of the category
 *         UpdAt:
 *           type: string
 *           format: date-time
 *           description: The date and time when the category was last updated
 *         IsDelete:
 *           type: boolean
 *           description: Indicates whether the category is marked as deleted (true) or active (false)
 * 
 * tags:
 *   name: Category
 *   description: API to manipulate category data
 * securityDefinitions:
 *   bearerAuth:
 *     type: apiKey
 *     name: Authorization
 *     in: header
 * /api/category:
 *   get:
 *     summary: Lists all the categories
 *     security:
 *       - bearerAuth: []
 *     tags: [Category]
 *     responses:
 *       200:
 *         description: The list of the categories
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Categories'
 * 
 *   post:
 *     summary: Create a new category
 *     security:
 *       - bearerAuth: []
 *     tags: [Category]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Categories'
 *     responses:
 *       200:
 *         description: The created category.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Categories'
 *       500:
 *         description: Some server error
 * 
 * /api/category/{id}:
 *   get:
 *     summary: Get the category by id
 *     security:
 *       - bearerAuth: []
 *     tags: [Category]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: string
 *         required: true
 *         description: The category id
 *     responses:
 *       200:
 *         description: The category response by id
 *         contens:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Categories'
 *       404:
 *         description: The category was not found
 * 
 *   patch:
 *    summary: Update the category by the id
 *    security:
 *      - bearerAuth: []
 *    tags: [Category]
 *    parameters:
 *      - in: path
 *        name: id
 *        schema:
 *          type: string
 *        required: true
 *        description: The category id
 *    requestBody:
 *      required: true
 *      content:
 *        application/json:
 *          schema:
 *            $ref: '#/components/schemas/Categories'
 *    responses:
 *      200:
 *        description: The category was updated
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/Categories'
 *      404:
 *        description: The category was not found
 *      500:
 *        description: Some error happened
 * 
 *   delete:
 *     summary: Remove the category by id
 *     security:
 *       - bearerAuth: []
 *     tags: [Category]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: string
 *         required: true
 *         description: The category id
 *
 *     responses:
 *       200:
 *         description: The category was deleted
 *       404:
 *         description: The category was not found
 */

const express = require("express");
const router = express.Router();
const {authentication} = require("../middlewares/authentication")
const Category = require("../controllers/categoryController")

router.get("/category", authentication, Category.GetAll);
router.get("/category/:id", authentication, Category.GetOne);
router.post("/category", authentication, Category.Post);
router.patch("/category/:id", authentication, Category.Patch);
router.delete("/category/:id", authentication, Category.Delete);

module.exports = router;