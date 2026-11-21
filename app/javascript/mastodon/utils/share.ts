/**
 * Open native share menu, ignoring menu dismissal
 */
export async function share(data: ShareData): Promise<void> {
  try {
    await navigator.share(data);
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      return;
    }

    console.error('Native browser sharing failed', error);
  }
}
