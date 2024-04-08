import 'dotenv/config'; // see https://github.com/motdotla/dotenv#how-do-i-use-dotenv-with-import
import express, { Request, Response } from 'express';

// require('dotenv').config();
require('dotenv').config({ path: `.env.${process.env.NODE_ENV}` });

console.log(process.env); // remove this after you've confirmed it working

const app = express();

app.get('/', (req: Request, res: Response) => res.send('It works'));

app.get('/hello-nodejs-typescript', (req: Request, res: Response) => res.send('Hello World!!!'));

const port = process.env.PORT || 3000; // Fallback to 3000 if process.env.PORT is not defined
app.listen(port, () => console.log(`Example app listening on port ${port}!`));
