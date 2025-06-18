# Feature Enhancement Analysis of Fundoscopic Images for Diabetic Retinopathy Classification

## 🔍 Project Overview

This project explores how different preprocessing techniques can enhance fundoscopic images to improve the classification accuracy of diabetic retinopathy (DR) using Support Vector Machines (SVM). Six enhancement combinations were applied to a custom-labeled dataset of 831 fundus images, resulting in a significant boost in classification performance — with the best accuracy reaching **94.76%**.

## 🎯 Motivation

Manual screening of retinal images is time-consuming, error-prone, and inaccessible in remote areas. Enhancing fundus images in ways that emphasize specific lesion features (like hemorrhages and hard exudates) can dramatically improve early DR detection without needing high-complexity deep learning models.

## 🧠 Key Contributions

- Systematic comparison of **6 preprocessing combinations** involving noise removal, contrast enhancement, and edge sharpening.
- Use of uncommon techniques like **TBCSSR** and **BBCCE** in fundus image enhancement.
- Demonstrated that preprocessing alone can raise classification accuracy by over **11.7%**.

## 📂 Dataset

- **Total images:** 831 fundus images  
  - **Normal:** 522  
  - **Hemorrhage / Microaneurysms:** 134  
  - **Hard exudates:** 175  
- **Split:** 70% training, 30% testing
- High-distortion images were excluded manually.

> 📁 *Note:* Dataset is not included. You may refer to Gholamy et al. (2018) or use publicly available fundus datasets such as [APTOS 2019](https://www.kaggle.com/competitions/aptos2019-blindness-detection/data).

## ⚙️ Preprocessing Combinations

| ID | Noise Removal         | Contrast Enhancement     | Edge Enhancement                |
|----|------------------------|---------------------------|----------------------------------|
| C1 | Median filter          | CLAHE                     | Unsharp masking                  |
| C2 | Gaussian filter        | CLAHE                     | Laplacian Edge Enhancement                                |
| C3 | Anisotropic diffusion  | BBCCE                     | Unsharp masking      |
| C4 | Median filter          | BBCCE                     | Laplacian Edge Enhancement                                |
| C5 | Median filter          | TBCSSR                         | Laplacian Edge Enhancement               |
| C6 | Anisotropic diffusion  | TBCSSR                    | Unsharp masking      |

## 🧪 Classification

- **Classifier:** Support Vector Machine (SVM)
- **Features extracted** from enhanced images before classification.
- **Evaluation Metrics:** Accuracy, Confusion Matrix, F1 Score, PSNR

## 📈 Results Snapshot

### 🔬 Visual Comparison: Hard Exudate Enhancement

[Hard Exudate Enhancement](Images\enhancement_results.jpg)

**Zoom in of the hard exudate lesion before and after preprocessing.**  
(a) Original image. (b) Image enhanced by C1. (c) Image enhanced by C2. (d) Image enhanced by C3. (e) Image enhanced by C4. (f) Image enhanced by C5. (g) Image enhanced by C6.

### 📊 Performance Metrics for Each Preprocessing Combination

| Combination | Accuracy (%) | F1 Score (Normal / Exudates / Hemorrhage) | PSNR (avg) |
|-------------|---------------|--------------------------------------------|------------|
| C1 | 92.95% | 0.990 / 0.761 / 0.857 | 27.1922 |
| C2 | 93.95%   | 0.9970 / 0.8194 / 0.8585 | 25.9661   |
| **C3**   | **94.76**  | **1.0 / 0.8763 / 0.8312**        | **18.2111**  |
| C4  |  93.15% | 1.0 / 0.8048 / 0.8211 |  19.1211 |  
| C5 |  91.67% | 0.9873 / 0.7676 / 0.8202 | 19.7226  |
| C6  | 90.23%  | 0.9843 / 0.7061 / 0.8147 | 18.7202  |

---

## 🛠 How to Run the Code

> 💡 **Requirements:** MATLAB with Image Processing Toolbox

1. Clone the repository

   ```bash
   git clone https://github.com/your-username/FundusEnhancement-DR-Classification.git
   cd FundusEnhancement-DR-Classification

## 📚 More Details

You can find full details of the methodology, background, and evaluation in the thesis report:

📄 [Thesis](https://drive.google.com/file/d/10RyT8yCEn2WJKk_uBNciZiavWSRO8dRV/view?usp=drivesdk)
