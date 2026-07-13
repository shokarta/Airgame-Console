import QtQml

QtObject {
	id: funcAPI

	function parseIsoUtcToDate(iso) {
		const m = iso.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.(\d+?)Z$/);
		if (!m) { return new Date(iso); }		// Fallback: let JS try to parse (handles cases without fractional part, etc.)

		const [_, y, mo, d, h, mi, s, frac] = m;
		const ms = (frac + "000").slice(0, 3);		// Take only the first 3 digits as milliseconds (pad if shorter)

		return new Date(Date.UTC(parseInt(y, 10), parseInt(mo, 10) - 1, parseInt(d, 10), parseInt(h, 10), parseInt(mi, 10), parseInt(s, 10), parseInt(ms, 10)));
	}

	function getValueFromPrice(input, options = {}) {
		if (input === null) return null;
		const {
			decimalHint,
			allowSingleSepAsDecimal = true,
		} = options;

		let str = String(input).trim();

		// Normalize unicode spaces (NBSP, thin space, narrow NBSP, etc.) to regular space
		// and remove all spaces entirely (since many locales use them as group separators).
		str = str
		.replace(/[\u00A0\u202F\u2007\u2009\u200A\u2008\u2006\u2005\u2004\u2003\u2002]/g, ' ')
		.replace(/\s+/g, ''); // remove spaces

		if (!str) return null;

		// Detect negative via parentheses or leading '-'
		let negative = false;
		if (str.startsWith('(') && str.endsWith(')')) {
			negative = true;
			str = str.slice(1, -1);
		}
		if (str.startsWith('-')) {
			negative = true;
			str = str.slice(1);
		}
		// Also handle trailing minus (some formats): "123,45-"
		if (str.endsWith('-')) {
			negative = true;
			str = str.slice(0, -1);
		}

		// Strip currency symbols and alphabetic codes, keep digits and separators.
		// Allow digits, comma, dot, apostrophe, plus/minus (minus handled), and nothing else.
		// We also keep plus for completeness.
		str = str.replace(/[^\d.,'’+-]/g, '');

		// If string is now empty or only punctuation, fail
		if (!/\d/.test(str)) return null;

		// Unify apostrophes (both ' and ’) as a grouping candidate
		str = str.replace(/’/g, "'");

		// If caller provided decimalHint, we honor it
		let decimalSep = null;
		if (decimalHint === 'comma') decimalSep = ',';
		else if (decimalHint === 'dot') decimalSep = '.';

		const hasComma = str.includes(',');
		const hasDot = str.includes('.');
		const hasApos = str.includes("'");

		// Heuristics to decide decimal separator when not forced:
		if (!decimalSep) {
			if (hasComma && hasDot) {
				// Both present: usually one is thousands, one is decimal.
				// Common patterns:
				//  "1,234.56" -> dot is decimal
				//  "1.234,56" -> comma is decimal
				// Decide by the *last* occurrence among comma/dot: usually the decimal
				const lastComma = str.lastIndexOf(',');
				const lastDot = str.lastIndexOf('.');
				decimalSep = lastDot > lastComma ? '.' : ',';
			}
			else if (hasComma && !hasDot) {
				// Only comma present: may be decimal or thousands
				// If only one comma and exactly 3 digits after -> likely thousands
				const parts = str.split(',');
				if (parts.length === 2 && parts[1].length === 3 && /\d/.test(parts[0])) {
					// treat as thousands separator, no decimal
					decimalSep = null;
				}
				else {
					decimalSep = allowSingleSepAsDecimal ? ',' : null;
				}
			}
			else if (!hasComma && hasDot) {
				// Only dot present
				const parts = str.split('.');
				if (parts.length === 2 && parts[1].length === 3 && /\d/.test(parts[0])) {
					decimalSep = null; // likely thousands
				}
				else {
					decimalSep = allowSingleSepAsDecimal ? '.' : null;
				}
			}
			else {
				// Neither comma nor dot present; could have apostrophes for grouping only
				decimalSep = null;
			}
		}

		// Remove all grouping separators: spaces already removed; remove apostrophes and the non-decimal of comma/dot
		// We'll rebuild a normalized number with '.' as decimal.
		let digits = str;

		// If decimalSep is determined, separate integer and decimal parts by the *last* occurrence of decimalSep
		// Everything else (., , ') should be treated as grouping and removed.
		let intPart = digits;
		let fracPart = '';

		const splitByLast = (s, sep) => {
			const idx = s.lastIndexOf(sep);
			if (idx === -1) return [s, ''];
			return [s.slice(0, idx), s.slice(idx + 1)];
		};

		if (decimalSep === ',' || decimalSep === '.') {
			[intPart, fracPart] = splitByLast(digits, decimalSep);
			// Remove all grouping candidates from intPart
			intPart = intPart.replace(/[.,']/g, '');
			// Remove all grouping candidates from fracPart (just in case)
			fracPart = fracPart.replace(/[.,']/g, '');
		}
		else {
			// No decimal separator determined → remove grouping and parse as integer
			intPart = intPart.replace(/[.,']/g, '');
		}

		// Construct canonical numeric string
		let canonical = fracPart ? `${intPart}.${fracPart}` : intPart;

		// Guard: canonical must be digits optionally with a single dot
		if (!/^\d+(\.\d+)?$/.test(canonical)) return null;

		let value = Number(canonical);
		if (!Number.isFinite(value)) return null;
		if (negative) value = -value;
		return value;
	}


	function jsonToForm(json) {
		const params = new URLSearchParams();

		for (const key in json) {
			const value = json[key];

			if (Array.isArray(value)) { value.forEach(v => params.append(key + "[]", v)); }
			else { params.append(key, value); }
		}

		return params.toString();
	}


	function formatDurationCompactSigned(ms) {
		// Determine sign (zero is considered positive)
		const sign = (ms < 0) ? "-" : "+";

		// Work with absolute value for breakdown
		ms = Math.abs(Math.floor(ms) || 0);

		const secTotal = Math.floor(ms / 1000);
		const days = Math.floor(secTotal / 86400);            // 24 * 60 * 60
		const hours = Math.floor((secTotal % 86400) / 3600);  // remainder after days
		const minutes = Math.floor((secTotal % 3600) / 60);   // remainder after hours
		const seconds = secTotal % 60;

		return `${sign}${days}d ${hours}h ${minutes}m ${seconds}s`;
	}

}
