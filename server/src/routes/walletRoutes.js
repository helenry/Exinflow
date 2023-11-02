/**
 * @swagger
 * components:
 *   schemas:
 *     Wallets:
 *       type: object
 *       required:
 *         - Name
 *         - InitialSaldo
 *       properties:
 *         Id:
 *           type: string
 *           description: The unique identifier of the wallet
 *         Name:
 *           type: string
 *           description: The name of the wallet
 *         InitialSaldo:
 *           type: number
 *           description: The initial balance of the wallet
 *         CrtAt:
 *           type: string
 *           format: date-time
 *           description: The date and time when the wallet was created
 *         CrtBy:
 *           type: string
 *           description: The creator of the wallet
 *         UpdAt:
 *           type: string
 *           format: date-time
 *           description: The date and time when the wallet was last updated
 *         IsDelete:
 *           type: boolean
 *           description: Indicates whether the wallet is marked as deleted (true) or active (false)
 * 
 * tags:
 *   name: Wallet
 *   description: API to manipulate wallet data
 * securityDefinitions:
 *   bearerAuth:
 *     type: apiKey
 *     name: Authorization
 *     in: header
 * /api/wallet:
 *   get:
 *     summary: Lists all the wallets
 *     security:
 *       - bearerAuth: []
 *     tags: [Wallet]
 *     responses:
 *       200:
 *         description: The list of the wallets
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Wallets'
 * 
 *   post:
 *     summary: Create a new wallet
 *     security:
 *       - bearerAuth: []
 *     tags: [Wallet]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Wallets'
 *     responses:
 *       200:
 *         description: The created wallet.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Wallets'
 *       500:
 *         description: Some server error
 * 
 * /api/wallet/{id}:
 *   get:
 *     summary: Get the wallet by id
 *     security:
 *       - bearerAuth: []
 *     tags: [Wallet]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: string
 *         required: true
 *         description: The wallet id
 *     responses:
 *       200:
 *         description: The wallet response by id
 *         contens:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Wallets'
 *       404:
 *         description: The wallet was not found
 * 
 *   patch:
 *    summary: Update the wallet by the id
 *    security:
 *      - bearerAuth: []
 *    tags: [Wallet]
 *    parameters:
 *      - in: path
 *        name: id
 *        schema:
 *          type: string
 *        required: true
 *        description: The wallet id
 *    requestBody:
 *      required: true
 *      content:
 *        application/json:
 *          schema:
 *            $ref: '#/components/schemas/Wallets'
 *    responses:
 *      200:
 *        description: The wallet was updated
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/Wallets'
 *      404:
 *        description: The wallet was not found
 *      500:
 *        description: Some error happened
 * 
 *   delete:
 *     summary: Remove the wallet by id
 *     security:
 *       - bearerAuth: []
 *     tags: [Wallet]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: string
 *         required: true
 *         description: The wallet id
 *
 *     responses:
 *       200:
 *         description: The wallet was deleted
 *       404:
 *         description: The wallet was not found
 */

const express = require("express");
const router = express.Router();
const {authentication} = require("../middlewares/authentication")
const Wallet = require("../controllers/walletController")

router.get("/wallet", authentication, Wallet.GetAll);
router.get("/wallet/:id", authentication, Wallet.GetOne);
router.post("/wallet", authentication, Wallet.Post);
router.patch("/wallet/:id", authentication, Wallet.Patch);
router.delete("/wallet/:id", authentication, Wallet.Delete);

module.exports = router;