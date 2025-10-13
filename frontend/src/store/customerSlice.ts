import { createSlice, PayloadAction, createAsyncThunk } from '@reduxjs/toolkit';
import customerService from '../services/customerService';

export interface Customer {
  id: number;
  name: string;
  email: string;
  phone: string;
  address: string;
  createdAt: string;
  updatedAt: string;
}

interface CustomerState {
  customers: Customer[];
  selectedCustomer: Customer | null;
  loading: boolean;
  error: string | null;
}

const initialState: CustomerState = {
  customers: [],
  selectedCustomer: null,
  loading: false,
  error: null
};

export const fetchCustomers = createAsyncThunk(
  'customers/fetchAll',
  async (_: void, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const customers = await customerService.getAllCustomers();
      return customers;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch customers');
    }
  }
);

export const fetchCustomerById = createAsyncThunk(
  'customers/fetchById',
  async (id: number, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const customer = await customerService.getCustomerById(id);
      return customer;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch customer');
    }
  }
);

export const createCustomer = createAsyncThunk(
  'customers/create',
  async (customerData: any, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const customer = await customerService.createCustomer(customerData);
      return customer;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to create customer');
    }
  }
);

export const updateCustomer = createAsyncThunk(
  'customers/update',
  async (customerData: any, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const customer = await customerService.updateCustomer(customerData);
      return customer;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to update customer');
    }
  }
);

export const deleteCustomer = createAsyncThunk(
  'customers/delete',
  async (id: number, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      await customerService.deleteCustomer(id);
      return id;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to delete customer');
    }
  }
);

export const customerSlice = createSlice({
  name: 'customers',
  initialState,
  reducers: {
    setSelectedCustomer: (state: CustomerState, action: PayloadAction<Customer | null>) => {
      state.selectedCustomer = action.payload;
    },
    clearError: (state: CustomerState) => {
      state.error = null;
    }
  },
  extraReducers: (builder: any) => {
    builder
      // Fetch all customers
      .addCase(fetchCustomers.pending, (state: CustomerState) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchCustomers.fulfilled, (state: CustomerState, action: PayloadAction<Customer[]>) => {
        state.loading = false;
        state.customers = action.payload;
      })
      .addCase(fetchCustomers.rejected, (state: CustomerState, action: any) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // Fetch customer by ID
      .addCase(fetchCustomerById.fulfilled, (state: CustomerState, action: PayloadAction<Customer>) => {
        state.selectedCustomer = action.payload;
      })
      // Create customer
      .addCase(createCustomer.fulfilled, (state: CustomerState, action: PayloadAction<Customer>) => {
        state.customers.push(action.payload);
      })
      // Update customer
      .addCase(updateCustomer.fulfilled, (state: CustomerState, action: PayloadAction<Customer>) => {
        const index = state.customers.findIndex(customer => customer.id === action.payload.id);
        if (index !== -1) {
          state.customers[index] = action.payload;
        }
        if (state.selectedCustomer && state.selectedCustomer.id === action.payload.id) {
          state.selectedCustomer = action.payload;
        }
      })
      // Delete customer
      .addCase(deleteCustomer.fulfilled, (state: CustomerState, action: PayloadAction<number>) => {
        state.customers = state.customers.filter(customer => customer.id !== action.payload);
        if (state.selectedCustomer && state.selectedCustomer.id === action.payload) {
          state.selectedCustomer = null;
        }
      });
  }
});

export const { setSelectedCustomer, clearError } = customerSlice.actions;

export default customerSlice.reducer;