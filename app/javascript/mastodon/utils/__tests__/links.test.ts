import { decodeIDNA } from '../links'; // Update this path to match your file

describe('decodeIDNA', () => {
  it('should return plain ASCII domains unchanged', () => {
    expect(decodeIDNA('example.com')).toBe('example.com');
    expect(decodeIDNA('sub.domain.co.uk')).toBe('sub.domain.co.uk');
  });

  it('should correctly decode a single Punycode segment', () => {
    // xn--maana-pta -> mañana
    expect(decodeIDNA('xn--maana-pta.com')).toBe('mañana.com');
  });

  it('should correctly decode multi-segment internationalized domains', () => {
    // xn--mller-kva -> müller
    // xn--bcher-kva -> bücher
    expect(decodeIDNA('xn--mller-kva.xn--bcher-kva.de')).toBe(
      'müller.bücher.de',
    );
  });

  it('should handle mixed ASCII and Punycode segments', () => {
    // xn--caf-dma -> café
    expect(decodeIDNA('sub.xn--caf-dma.example.com')).toBe(
      'sub.café.example.com',
    );
  });

  it('should return an empty string if given an empty string', () => {
    expect(decodeIDNA('')).toBe('');
  });

  it('should handle domains that contain "xn--" but not as a prefix', () => {
    expect(decodeIDNA('not-xn--prefix.com')).toBe('not-xn--prefix.com');
  });

  it('should correctly decode domains containing emojis', () => {
    // xn--i-7iq -> i❤
    expect(decodeIDNA('xn--i-7iq.com')).toBe('i❤.com');
  });

  it('should correctly decode complex mixed emoji and text domains', () => {
    // xn--068h -> 🚢
    expect(decodeIDNA('sub.xn--068h.example.com')).toBe('sub.🚢.example.com');
  });
});
