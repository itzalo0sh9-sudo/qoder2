import axios from 'axios';

// Properly typed environment variable access
const API_BASE_URL = process.env.REACT_APP_SALES_API_URL || 'http://localhost:8001';

interface Notification {
  id: number;
  title: string;
  message: string;
  type: 'info' | 'success' | 'warning' | 'error';
  read: boolean;
  createdAt: string;
}

class NotificationService {
  private getAuthToken(): string | null {
    return localStorage.getItem('accessToken');
  }

  private getAuthHeaders() {
    const token = this.getAuthToken();
    return token ? { Authorization: `Bearer ${token}` } : {};
  }

  async getAllNotifications(): Promise<Notification[]> {
    try {
      const response = await axios.get<Notification[]>(`${API_BASE_URL}/api/notifications`, {
        headers: this.getAuthHeaders()
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching notifications:', error);
      throw error;
    }
  }

  async markAsRead(id: number): Promise<Notification> {
    try {
      const response = await axios.put<Notification>(
        `${API_BASE_URL}/api/notifications/${id}/read`,
        {},
        {
          headers: this.getAuthHeaders()
        }
      );
      return response.data;
    } catch (error) {
      console.error(`Error marking notification ${id} as read:`, error);
      throw error;
    }
  }

  async markAllAsRead(): Promise<void> {
    try {
      await axios.put(
        `${API_BASE_URL}/api/notifications/read-all`,
        {},
        {
          headers: this.getAuthHeaders()
        }
      );
    } catch (error) {
      console.error('Error marking all notifications as read:', error);
      throw error;
    }
  }
}

export default new NotificationService();