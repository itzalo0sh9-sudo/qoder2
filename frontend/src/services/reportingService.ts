import axios from 'axios';

// Properly typed environment variable access
const API_BASE_URL = process.env.REACT_APP_SALES_API_URL || 'http://localhost:8001';

interface ReportData {
  title: string;
  data: any;
  generatedAt: string;
}

interface SalesReport {
  period: string;
  totalRevenue: number;
  totalOrders: number;
  averageOrderValue: number;
  topProducts: {
    productId: number;
    productName: string;
    quantitySold: number;
    revenue: number;
  }[];
}

class ReportingService {
  private getAuthToken(): string | null {
    return localStorage.getItem('accessToken');
  }

  private getAuthHeaders() {
    const token = this.getAuthToken();
    return token ? { Authorization: `Bearer ${token}` } : {};
  }

  async getSalesReport(period: string = 'month'): Promise<SalesReport> {
    try {
      const response = await axios.get<SalesReport>(`${API_BASE_URL}/api/reports/sales?period=${period}`, {
        headers: this.getAuthHeaders()
      });
      return response.data;
    } catch (error) {
      console.error('Error fetching sales report:', error);
      throw error;
    }
  }

  async generateReport(reportType: string, params: any = {}): Promise<ReportData> {
    try {
      const response = await axios.post<ReportData>(
        `${API_BASE_URL}/api/reports/generate`,
        { reportType, ...params },
        {
          headers: {
            ...this.getAuthHeaders(),
            'Content-Type': 'application/json'
          }
        }
      );
      return response.data;
    } catch (error) {
      console.error(`Error generating ${reportType} report:`, error);
      throw error;
    }
  }
}

export default new ReportingService();