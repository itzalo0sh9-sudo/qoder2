import axios from 'axios';

// Properly typed environment variable access
const API_BASE_URL = process.env.REACT_APP_SALES_API_URL || 'http://localhost:8001';

interface OrderItem {
  id: number;
  productId: number;
  productName: string;
  quantity: number;
  price: number;
  total: number;
}

interface Order {
  id: number;
  customerId: number;
  customerName: string;
  status: 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  paymentStatus: 'pending' | 'paid' | 'failed' | 'refunded';
  items: OrderItem[];
  subtotal: number;
  tax: number;
  shipping: number;
  total: number;
  createdAt: string;
  updatedAt: string;
}

interface OrderCreate {
  customerId: number;
  items: {
    productId: number;
    quantity: number;
  }[];
  tax: number;
  shipping: number;
}

interface OrderUpdate {
  id: number;
  status?: 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  paymentStatus?: 'pending' | 'paid' | 'failed' | 'refunded';
}

class OrderService {
  private getAuthToken(): string | null {
    return localStorage.getItem('accessToken');
  }

  private getAuthHeaders() {
    const token = this.getAuthToken();
    return token ? { Authorization: `Bearer ${token}` } : {};
  }

  async getAllOrders(): Promise<Order[]> {
    try {
      const response = await axios.get<Order[]>(`${API_BASE_URL}/api/orders`, {
        headers: this.getAuthHeaders()
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching orders:', error);
      throw error;
    }
  }

  async getOrderById(id: number): Promise<Order> {
    try {
      const response = await axios.get<Order>(`${API_BASE_URL}/api/orders/${id}`, {
        headers: this.getAuthHeaders()
      });
      return response.data;
    } catch (error) {
      console.error(`Error fetching order ${id}:`, error);
      throw error;
    }
  }

  async createOrder(orderData: OrderCreate): Promise<Order> {
    try {
      const response = await axios.post<Order>(`${API_BASE_URL}/api/orders`, orderData, {
        headers: {
          ...this.getAuthHeaders(),
          'Content-Type': 'application/json'
        }
      });
      return response.data;
    } catch (error) {
      console.error('Error creating order:', error);
      throw error;
    }
  }

  async updateOrder(orderData: OrderUpdate): Promise<Order> {
    try {
      const response = await axios.put<Order>(
        `${API_BASE_URL}/api/orders/${orderData.id}`,
        orderData,
        {
          headers: {
            ...this.getAuthHeaders(),
            'Content-Type': 'application/json'
          }
        }
      );
      return response.data;
    } catch (error) {
      console.error(`Error updating order ${orderData.id}:`, error);
      throw error;
    }
  }

  async deleteOrder(id: number): Promise<void> {
    try {
      await axios.delete(`${API_BASE_URL}/api/orders/${id}`, {
        headers: this.getAuthHeaders()
      });
    } catch (error) {
      console.error(`Error deleting order ${id}:`, error);
      throw error;
    }
  }
}

export default new OrderService();