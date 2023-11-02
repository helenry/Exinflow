/**
 * @swagger
 * components:
 *   schemas:
 *     Transactions:
 *       type: object
 *       required:
 *         - TransactionType
 *         - Amount
 *       properties:
 *         Id:
 *           type: string
 *           description: The unique identifier of the transaction
 *         TransactionType:
 *           type: number
 *           description: The type of the transaction
 *         CategoryId:
 *           type: number
 *           description: The category of the transaction
 *         WalletFromId:
 *           type: number
 *           description: The wallet from which the transaction is done
 *         WalletToId:
 *           type: number
 *           description: The wallet to which the transaction is done
 *         Amount:
 *           type: number
 *           description: The amount of the transaction
 *         Description:
 *           type: string
 *           description: The description of the transaction
 *         CrtAt:
 *           type: string
 *           format: date-time
 *           description: The date and time when the transaction was created
 *         CrtBy:
 *           type: string
 *           description: The creator of the transaction
 *         UpdAt:
 *           type: string
 *           format: date-time
 *           description: The date and time when the transaction was last updated
 *         IsDelete:
 *           type: boolean
 *           description: Indicates whether the transaction is marked as deleted (true) or active (false)
 * 
 * tags:
 *   name: Transaction
 *   description: API to manipulate transaction data
 * securityDefinitions:
 *   bearerAuth:
 *     type: apiKey
 *     name: Authorization
 *     in: header
 * /api/transaction:
 *   get:
 *     summary: Lists all the transactions
 *     security:
 *       - bearerAuth: []
 *     tags: [Transaction]
 *     responses:
 *       200:
 *         description: The list of the transactions
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Transactions'
 * 
 *   post:
 *     summary: Create a new transaction
 *     security:
 *       - bearerAuth: []
 *     tags: [Transaction]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Transactions'
 *     responses:
 *       200:
 *         description: The created transaction.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Transactions'
 *       500:
 *         description: Some server error
 * 
 * /api/transaction/{id}:
 *   get:
 *     summary: Get the transaction by id
 *     security:
 *       - bearerAuth: []
 *     tags: [Transaction]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: string
 *         required: true
 *         description: The transaction id
 *     responses:
 *       200:
 *         description: The transaction response by id
 *         contens:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Transactions'
 *       404:
 *         description: The transaction was not found
 * 
 *   patch:
 *    summary: Update the transaction by the id
 *    security:
 *      - bearerAuth: []
 *    tags: [Transaction]
 *    parameters:
 *      - in: path
 *        name: id
 *        schema:
 *          type: string
 *        required: true
 *        description: The transaction id
 *    requestBody:
 *      required: true
 *      content:
 *        application/json:
 *          schema:
 *            $ref: '#/components/schemas/Transactions'
 *    responses:
 *      200:
 *        description: The transaction was updated
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/Transactions'
 *      404:
 *        description: The transaction was not found
 *      500:
 *        description: Some error happened
 * 
 *   delete:
 *     summary: Remove the transaction by id
 *     security:
 *       - bearerAuth: []
 *     tags: [Transaction]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: string
 *         required: true
 *         description: The transaction id
 *
 *     responses:
 *       200:
 *         description: The transaction was deleted
 *       404:
 *         description: The transaction was not found
 */

const express = require("express");
const router = express.Router();
const {authentication} = require("../middlewares/authentication")
const Transaction = require("../controllers/transactionController")

router.get("/transaction", authentication, Transaction.GetAll);
router.get("/transaction/:id", authentication, Transaction.GetOne);
router.post("/transaction", authentication, Transaction.Post);
router.patch("/transaction/:id", authentication, Transaction.Patch);
router.delete("/transaction/:id", authentication, Transaction.Delete);

module.exports = router;