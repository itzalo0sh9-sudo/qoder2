import axios from 'axios';

// Properly typed environment variable access
const API_BASE_URL = process.env.REACT_APP_SALES_API_URL || 'http://localhost:8001';

interface Customer {
  id: number;
  name: string;
  email: string;
  phone: string;
  address: string;
  createdAt: string;
  updatedAt: string;
}

interface CustomerCreate {
  name: string;
  email: string;
  phone: string;
  address: string;
}

interface CustomerUpdate {
  id: number;
  name?: string;
  email?: string;
  phone?: string;
  address?: string;
}

class CustomerService {
  private getAuthToken(): string | null {
    return localStorage.getItem('accessToken');
  }

  private getAuthHeaders() {
    const token = this.getAuthToken();
    return token ? { Authorization: `Bearer ${token}` } : {};
  }

  async getAllCustomers(): Promise<Customer[]> {
    try {
      const response = await axios.get<Customer[]>(`${API_BASE_URL}/api/customers`, {
        headers: this.getAuthHeaders()
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching customers:', error);
      throw error;
    }
  }

  async getCustomerById(id: number): Promise<Customer> {
    try {
      const response = await axios.get<Customer>(`${API_BASE_URL}/api/customers/${id}`, {
        headers: this.getAuthHeaders()
      });
      return response.data;
    } catch (error) {
      console.error(`Error fetching customer ${id}:`, error);
      throw error;
    }
  }

  async createCustomer(customerData: CustomerCreate): Promise<Customer> {
    try {
      const response = await axios.post<Customer>(`${API_BASE_URL}/api/customers`, customerData, {
        headers: {
          ...this.getAuthHeaders(),
          'Content-Type': 'application/json'
        }
      });
      return response.data;
    } catch (error) {
      console.error('Error creating customer:', error);
      throw error;
    }
  }

  async updateCustomer(customerData: CustomerUpdate): Promise<Customer> {
    try {
      const response = await axios.put<Customer>(
        `${API_BASE_URL}/api/customers/${customerData.id}`,
        customerData,
        {
          headers: {
            ...this.getAuthHeaders(),
            'Content-Type': 'application/json'
          }
        }
      );
      return response.data;
    } catch (error) {
      console.error(`Error updating customer ${customerData.id}:`, error);
      throw error;
    }
  }

  async deleteCustomer(id: number): Promise<void> {
    try {
      await axios.delete(`${API_BASE_URL}/api/customers/${id}`, {
        headers: this.getAuthHeaders()
      });
    } catch (error) {
      console.error(`Error deleting customer ${id}:`, error);
      throw error;
    }
  }
}

export default new CustomerService();