import axios from 'axios';

// Properly typed environment variable access
const API_BASE_URL = process.env.REACT_APP_SALES_API_URL || 'http://localhost:8001';

interface Product {
  id: number;
  name: string;
  description: string;
  price: number;
  cost: number;
  stock: number;
  category: string;
  supplier: string;
  status: 'active' | 'inactive' | 'discontinued';
  createdAt: string;
  updatedAt: string;
}

interface ProductCreate {
  name: string;
  description: string;
  price: number;
  cost: number;
  stock: number;
  category: string;
  supplier: string;
  status: 'active' | 'inactive' | 'discontinued';
}

interface ProductUpdate {
  id: number;
  name?: string;
  description?: string;
  price?: number;
  cost?: number;
  stock?: number;
  category?: string;
  supplier?: string;
  status?: 'active' | 'inactive' | 'discontinued';
}

class ProductService {
  private getAuthToken(): string | null {
    return localStorage.getItem('accessToken');
  }

  private getAuthHeaders() {
    const token = this.getAuthToken();
    return token ? { Authorization: `Bearer ${token}` } : {};
  }

  async getAllProducts(): Promise<Product[]> {
    try {
      const response = await axios.get<Product[]>(`${API_BASE_URL}/api/products`, {
        headers: this.getAuthHeaders()
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching products:', error);
      throw error;
    }
  }

  async getProductById(id: number): Promise<Product> {
    try {
      const response = await axios.get<Product>(`${API_BASE_URL}/api/products/${id}`, {
        headers: this.getAuthHeaders()
      });
      return response.data;
    } catch (error) {
      console.error(`Error fetching product ${id}:`, error);
      throw error;
    }
  }

  async createProduct(productData: ProductCreate): Promise<Product> {
    try {
      const response = await axios.post<Product>(`${API_BASE_URL}/api/products`, productData, {
        headers: {
          ...this.getAuthHeaders(),
          'Content-Type': 'application/json'
        }
      });
      return response.data;
    } catch (error) {
      console.error('Error creating product:', error);
      throw error;
    }
  }

  async updateProduct(productData: ProductUpdate): Promise<Product> {
    try {
      const response = await axios.put<Product>(
        `${API_BASE_URL}/api/products/${productData.id}`,
        productData,
        {
          headers: {
            ...this.getAuthHeaders(),
            'Content-Type': 'application/json'
          }
        }
      );
      return response.data;
    } catch (error) {
      console.error(`Error updating product ${productData.id}:`, error);
      throw error;
    }
  }

  async deleteProduct(id: number): Promise<void> {
    try {
      await axios.delete(`${API_BASE_URL}/api/products/${id}`, {
        headers: this.getAuthHeaders()
      });
    } catch (error) {
      console.error(`Error deleting product ${id}:`, error);
      throw error;
    }
  }

  async getLowStockProducts(threshold: number = 10): Promise<Product[]> {
    try {
      const response = await axios.get<Product[]>(`${API_BASE_URL}/api/products/low-stock?threshold=${threshold}`, {
        headers: this.getAuthHeaders()
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching low stock products:', error);
      throw error;
    }
  }
}

export default new ProductService();