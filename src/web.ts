import { WebPlugin } from '@capacitor/core';

import type {
  ApplePayPlugin,
  CanMakePaymentsRequest,
  CanMakePaymentsResponse,
  CompletePaymentRequest,
  InitiatePaymentRequest,
  InitiatePaymentResponse,
} from './definitions';

export class ApplePayWeb extends WebPlugin implements ApplePayPlugin {
  private _paymentResponse?: PaymentResponse;

  constructor() {
    super({
      name: 'ApplePay',
      platforms: ['web'],
    });
  }
  
  async canMakePayments(
    options?: CanMakePaymentsRequest,
  ): Promise<CanMakePaymentsResponse> {
    if (!PaymentRequest) return { canMakePayments: false };

    const paymentMethodData = [
      {
        supportedMethods: 'https://apple.com/apple-pay'
      },
    ] as PaymentMethodData[];

    if (options?.networks) {
      paymentMethodData[0].data = { supportedNetworks: options.networks };
    }

    if (options?.capabilities) {
      paymentMethodData[0].data.merchantCapabilities = options.capabilities.map(c => c.replace('capability', 'supports'));
    }

    const details = {
      total: {
        label: 'Total',
        amount: {
          currency: 'USD',
          value: '0.00',
        },
      },
    };

    const paymentRequest = new PaymentRequest(paymentMethodData, details);

    const supportsApplePay = await paymentRequest.canMakePayment();

    return { canMakePayments: supportsApplePay };
  }

  async initiatePayment(request: InitiatePaymentRequest): Promise<InitiatePaymentResponse> {
    if (request.supportedNetworks && !(await this.canMakePayments({ networks: request.supportedNetworks, capabilities: request.merchantCapabilities })).canMakePayments) throw new Error('Apple Pay not available');
    else if ((await this.canMakePayments()).canMakePayments) throw new Error('Apple Pay not available');
    else if (this._paymentResponse) throw new Error('PaymentRequest already in progress');

    const paymentMethodData = [
      {
        supportedMethods: 'https://apple.com/apple-pay',
        data: {
          version: request.version || 8,
          merchantIdentifier: request.merchantIdentifier,
          countryCode: request.countryCode,
        }
      },
    ] as PaymentMethodData[];

    if (request.supportedNetworks) {
      paymentMethodData[0].data.supportedNetworks = request.supportedNetworks;
    }

    if (request.merchantCapabilities) {
      paymentMethodData[0].data.merchantCapabilities = request.merchantCapabilities.map(c => c.replace('capability', 'supports'));
    }

    const details = {
      total: {
        label: 'Total',
        amount: {
          currency: request.currencyCode,
          value: request.summaryItems.reduce((total, item) => total + Number(item.amount), 0).toFixed(request.currencyDecimalDigits ?? 2),
        },
      },
      displayItems: request.summaryItems.map(item => ({
        label: item.label,
        amount: {
          currency: request.currencyCode,
          value: item.amount,
        },
      })),
    };

    const paymentRequest = new PaymentRequest(paymentMethodData, details);

    this._paymentResponse = await paymentRequest.show();

    return this._paymentResponse.details as InitiatePaymentResponse;
  }

  async completeLastPayment({ status }: CompletePaymentRequest): Promise<void> {
    if (!this._paymentResponse) throw new Error('No PaymentRequest in progress');

    await this._paymentResponse.complete(status === 'failure' ? 'fail' : 'success');
    this._paymentResponse = undefined;
  }
}
