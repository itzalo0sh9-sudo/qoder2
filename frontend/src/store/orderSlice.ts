import { createSlice, PayloadAction, createAsyncThunk } from '@reduxjs/toolkit';
import orderService from '../services/orderService';

export interface OrderItem {
  id: number;
  productId: number;
  productName: string;
  quantity: number;
  price: number;
  total: number;
}

export interface Order {
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

interface OrderState {
  orders: Order[];
  selectedOrder: Order | null;
  loading: boolean;
  error: string | null;
}

const initialState: OrderState = {
  orders: [],
  selectedOrder: null,
  loading: false,
  error: null
};

export const fetchOrders = createAsyncThunk(
  'orders/fetchAll',
  async (_: void, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const orders = await orderService.getAllOrders();
      return orders;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch orders');
    }
  }
);

export const fetchOrderById = createAsyncThunk(
  'orders/fetchById',
  async (id: number, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const order = await orderService.getOrderById(id);
      return order;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch order');
    }
  }
);

export const createOrder = createAsyncThunk(
  'orders/create',
  async (orderData: any, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const order = await orderService.createOrder(orderData);
      return order;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to create order');
    }
  }
);

export const updateOrder = createAsyncThunk(
  'orders/update',
  async (orderData: any, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const order = await orderService.updateOrder(orderData);
      return order;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to update order');
    }
  }
);

export const deleteOrder = createAsyncThunk(
  'orders/delete',
  async (id: number, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      await orderService.deleteOrder(id);
      return id;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to delete order');
    }
  }
);

export const orderSlice = createSlice({
  name: 'orders',
  initialState,
  reducers: {
    setSelectedOrder: (state, action: PayloadAction<Order | null>) => {
      state.selectedOrder = action.payload;
    },
    clearError: (state) => {
      state.error = null;
    }
  },
  extraReducers: (builder) => {
    builder
      // Fetch all orders
      .addCase(fetchOrders.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchOrders.fulfilled, (state, action: PayloadAction<Order[]>) => {
        state.loading = false;
        state.orders = action.payload;
      })
      .addCase(fetchOrders.rejected, (state, action: any) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // Fetch order by ID
      .addCase(fetchOrderById.fulfilled, (state, action: PayloadAction<Order>) => {
        state.selectedOrder = action.payload;
      })
      // Create order
      .addCase(createOrder.fulfilled, (state, action: PayloadAction<Order>) => {
        state.orders.push(action.payload);
      })
      // Update order
      .addCase(updateOrder.fulfilled, (state, action: PayloadAction<Order>) => {
        const index = state.orders.findIndex(order => order.id === action.payload.id);
        if (index !== -1) {
          state.orders[index] = action.payload;
        }
        if (state.selectedOrder && state.selectedOrder.id === action.payload.id) {
          state.selectedOrder = action.payload;
        }
      })
      // Delete order
      .addCase(deleteOrder.fulfilled, (state, action: PayloadAction<number>) => {
        state.orders = state.orders.filter(order => order.id !== action.payload);
        if (state.selectedOrder && state.selectedOrder.id === action.payload) {
          state.selectedOrder = null;
        }
      });
  }
});

export const { setSelectedOrder, clearError } = orderSlice.actions;

export default orderSlice.reducer;