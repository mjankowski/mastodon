// Workaround for an upstream issue
// https://github.com/formatjs/formatjs/issues/7460#issuecomment-5869944271

import type { MessageDescriptor } from 'react-intl';

declare module 'react-intl' {
  export function defineMessages<
    K extends PropertyKey,
    T = MessageDescriptor,
    U extends Record<K, T> = Record<K, T>,
  >(messages: U): { readonly [P in keyof U]: Readonly<U[P]> };

  export function defineMessage<const D extends MessageDescriptor>(
    message: D,
  ): Readonly<D>;
}
