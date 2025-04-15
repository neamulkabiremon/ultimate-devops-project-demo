import ProductCatalogService from '../ProductCatalog.service';
import { Money } from '../../protos/demo';

// ✅ Fully mock the default exports to avoid real gRPC calls
jest.mock('../../gateways/rpc/ProductCatalog.gateway', () => {
  return {
    __esModule: true,
    default: {
      listProducts: jest.fn().mockResolvedValue({
        products: [
          { id: '1', name: 'Product A', priceUsd: { currencyCode: 'USD', units: 10, nanos: 0 } },
          { id: '2', name: 'Product B', priceUsd: { currencyCode: 'USD', units: 10, nanos: 0 } },
        ],
      }),
      getProduct: jest.fn().mockResolvedValue({
        id: '1',
        name: 'Product A',
        priceUsd: { currencyCode: 'USD', units: 10, nanos: 0 },
      }),
    },
  };
});

jest.mock('../../gateways/rpc/Currency.gateway', () => {
  return {
    __esModule: true,
    default: {
      convert: jest.fn().mockResolvedValue({
        currencyCode: 'EUR',
        units: 9,
        nanos: 500000000,
      }),
    },
  };
});

// ✅ Import mocks after mocking
import ProductCatalogGateway from '../../gateways/rpc/ProductCatalog.gateway';
import CurrencyGateway from '../../gateways/rpc/Currency.gateway';

const mockPrice: Money = {
  currencyCode: 'USD',
  units: 10,
  nanos: 0,
};

describe('ProductCatalogService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should return converted price if currency is different from USD', async () => {
    const result = await ProductCatalogService.getProductPrice(mockPrice, 'EUR');

    expect(CurrencyGateway.convert).toHaveBeenCalledWith(mockPrice, 'EUR');
    expect(result.currencyCode).toBe('EUR');
  });

  it('should return original price if currency is USD', async () => {
    const result = await ProductCatalogService.getProductPrice(mockPrice, 'USD');

    expect(result).toEqual(mockPrice);
    expect(CurrencyGateway.convert).not.toHaveBeenCalled();
  });

  it('should return original price if currency code is missing', async () => {
    const result = await ProductCatalogService.getProductPrice(mockPrice, '');

    expect(result).toEqual(mockPrice);
    expect(CurrencyGateway.convert).not.toHaveBeenCalled();
  });

  it('should return original price if currency code is null', async () => {
    const result = await ProductCatalogService.getProductPrice(mockPrice, null as unknown as string);

    expect(result).toEqual(mockPrice);
    expect(CurrencyGateway.convert).not.toHaveBeenCalled();
  });

  it('should list products with converted prices', async () => {
    const products = await ProductCatalogService.listProducts('EUR');

    expect(products).toHaveLength(2);
    expect(products[0].priceUsd.currencyCode).toBe('EUR');
    expect(CurrencyGateway.convert).toHaveBeenCalledTimes(2);
  });

  it('should get a single product with converted price', async () => {
    const product = await ProductCatalogService.getProduct('1', 'EUR');

    expect(product.id).toBe('1');
    expect(product.priceUsd.currencyCode).toBe('EUR');
  });
});