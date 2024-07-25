// utils.js

/**
 * Copies text to the clipboard.
 * @param {string} text - The text to copy.
 */
export function copyToClipboard(text : string) {
    if (navigator.clipboard) {
      // Modern clipboard API
      navigator.clipboard.writeText(text).catch((err) => {
        console.error('Failed to copy text: ', err);
      });
    } else {
      // Fallback for older browsers
      const textarea = document.createElement('textarea');
      textarea.value = text;
      document.body.appendChild(textarea);
      textarea.select();
      try {
        document.execCommand('copy');
        console.log('Text copied to clipboard');
      } catch (err) {
        console.error('Failed to copy text: ', err);
      }
      document.body.removeChild(textarea);
    }
  }
