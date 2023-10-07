// index.mjs
import express from "express";
import sharp from "sharp";
import multer from "multer";
import { PDFDocument } from "pdf-lib";

const app = express();
const port = process.env.PORT || 3000;

// Setup multer for file uploads
const storage = multer.memoryStorage(); // store the file in memory
const upload = multer({ storage: storage });

app.post("/reduce", upload.single("file"), async (req, res) => {
  const { quality } = req.body;
  try {
    if (!req.file) {
      return res.status(400).send("No file uploaded");
    }

    const uploadedFileSize = req.file.size; // Size in bytes

    const buffer = await sharp(req.file.buffer)
      .resize({ width: 500 }) // You can change this value or even make it dynamic based on user input
      .jpeg({ quality:  parseInt(quality) }) // Change quality to reduce the size
      .toBuffer();

    const reducedFileSize = buffer.length; // Size in bytes

    console.log(`Uploaded file size: ${uploadedFileSize} bytes`);
    console.log(`Reduced file size: ${reducedFileSize} bytes`);

    res.setHeader("Content-Type", "image/jpeg");
    res.send(buffer);
  } catch (error) {
    console.error("Error:", error);
    res.status(500).send("Server error");
  }
});

app.post("/reduce-pdf", upload.single("file"), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).send("No file uploaded");
    }

    const uploadedFileSize = req.file.size; // Size in bytes

    const existingPdfBytes = req.file.buffer;

    // Load a PDFDocument from the existing PDF bytes
    const pdfDoc = await PDFDocument.load(existingPdfBytes);

    // Serialize the PDFDocument to bytes
    const pdfBytes = await pdfDoc.save();

    const reducedFileSize = pdfBytes.length; // Size in bytes

    console.log(`Uploaded PDF file size: ${uploadedFileSize} bytes`);
    console.log(`Reduced PDF file size: ${reducedFileSize} bytes`);

    res.setHeader("Content-Type", "application/pdf");
    res.send(pdfBytes);
  } catch (error) {
    console.error("Error:", error);
    res.status(500).send("Server error");
  }
});

app.listen(port, () => {
  console.log(`File reducer API listening at http://localhost:${port}`);
});
