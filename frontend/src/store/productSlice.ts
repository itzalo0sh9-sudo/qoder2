import { createSlice, PayloadAction, createAsyncThunk } from '@reduxjs/toolkit';
import productService from '../services/productService';

export interface Product {
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

interface ProductState {
  products: Product[];
  selectedProduct: Product | null;
  loading: boolean;
  error: string | null;
}

const initialState: ProductState = {
  products: [],
  selectedProduct: null,
  loading: false,
  error: null
};

export const fetchProducts = createAsyncThunk(
  'products/fetchAll',
  async (_: void, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const products = await productService.getAllProducts();
      return products;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch products');
    }
  }
);

export const fetchProductById = createAsyncThunk(
  'products/fetchById',
  async (id: number, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const product = await productService.getProductById(id);
      return product;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch product');
    }
  }
);

export const createProduct = createAsyncThunk(
  'products/create',
  async (productData: any, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const product = await productService.createProduct(productData);
      return product;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to create product');
    }
  }
);

export const updateProduct = createAsyncThunk(
  'products/update',
  async (productData: any, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const product = await productService.updateProduct(productData);
      return product;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to update product');
    }
  }
);

export const deleteProduct = createAsyncThunk(
  'products/delete',
  async (id: number, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      await productService.deleteProduct(id);
      return id;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to delete product');
    }
  }
);

export const fetchLowStockProducts = createAsyncThunk(
  'products/fetchLowStock',
  async (threshold: number = 10, { rejectWithValue }: { rejectWithValue: Function }) => {
    try {
      const products = await productService.getLowStockProducts(threshold);
      return products;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch low stock products');
    }
  }
);

export const productSlice = createSlice({
  name: 'products',
  initialState,
  reducers: {
    setSelectedProduct: (state: ProductState, action: PayloadAction<Product | null>) => {
      state.selectedProduct = action.payload;
    },
    clearError: (state: ProductState) => {
      state.error = null;
    }
  },
  extraReducers: (builder: any) => {
    builder
      // Fetch all products
      .addCase(fetchProducts.pending, (state: ProductState) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchProducts.fulfilled, (state: ProductState, action: PayloadAction<Product[]>) => {
        state.loading = false;
        state.products = action.payload;
      })
      .addCase(fetchProducts.rejected, (state: ProductState, action: any) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // Fetch product by ID
      .addCase(fetchProductById.fulfilled, (state: ProductState, action: PayloadAction<Product>) => {
        state.selectedProduct = action.payload;
      })
      // Create product
      .addCase(createProduct.fulfilled, (state: ProductState, action: PayloadAction<Product>) => {
        state.products.push(action.payload);
      })
      // Update product
      .addCase(updateProduct.fulfilled, (state: ProductState, action: PayloadAction<Product>) => {
        const index = state.products.findIndex(product => product.id === action.payload.id);
        if (index !== -1) {
          state.products[index] = action.payload;
        }
        if (state.selectedProduct && state.selectedProduct.id === action.payload.id) {
          state.selectedProduct = action.payload;
        }
      })
      // Delete product
      .addCase(deleteProduct.fulfilled, (state: ProductState, action: PayloadAction<number>) => {
        state.products = state.products.filter(product => product.id !== action.payload);
        if (state.selectedProduct && state.selectedProduct.id === action.payload) {
          state.selectedProduct = null;
        }
      });
  }
});

export const { setSelectedProduct, clearError } = productSlice.actions;

export default productSlice.reducer;