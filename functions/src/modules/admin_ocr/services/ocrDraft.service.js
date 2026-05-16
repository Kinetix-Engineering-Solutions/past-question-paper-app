function normalizeWhitespace(value) {
  return (value || '').replace(/\r\n/g, '\n').replace(/\t/g, ' ').replace(/\s+/g, ' ').trim();
}

function normalizeMathDelimiters(value) {
  return (value || '')
    .replace(/\\\(/g, '$')
    .replace(/\\\)/g, '$')
    .replace(/\\\[/g, '$$')
    .replace(/\\\]/g, '$$');
}

function parseOptions(lines) {
  const options = [];
  const optionRegex = /^\s*[(\[]?([A-D])[)\].:\-]?\s+(.+)$/i;

  for (const line of lines) {
    const match = line.match(optionRegex);
    if (!match) {
      continue;
    }

    const optionLabel = match[1].toUpperCase();
    const optionText = normalizeMathDelimiters(normalizeWhitespace(match[2]));
    options.push({ label: optionLabel, text: optionText });
  }

  if (options.length < 2) {
    return [];
  }

  const map = { A: '', B: '', C: '', D: '' };
  for (const option of options) {
    if (Object.prototype.hasOwnProperty.call(map, option.label)) {
      map[option.label] = option.text;
    }
  }

  return [map.A, map.B, map.C, map.D];
}

function parseAnswer(lines, options) {
  const answerRegex = /^\s*(answer|ans|correct\s*answer)\s*[:\-]\s*(.+)$/i;

  for (const line of lines) {
    const answerMatch = line.match(answerRegex);
    if (!answerMatch) {
      continue;
    }

    const rawAnswer = normalizeMathDelimiters(normalizeWhitespace(answerMatch[2]));

    const letterMatch = rawAnswer.match(/^([A-D])\b/i);
    if (letterMatch) {
      return letterMatch[1].toUpperCase();
    }

    if (options.length > 0) {
      const normalized = rawAnswer.toLowerCase();
      const matchedIndex = options.findIndex((option) => option && option.toLowerCase() === normalized);
      if (matchedIndex >= 0) {
        return ['A', 'B', 'C', 'D'][matchedIndex];
      }
    }

    return rawAnswer;
  }

  return '';
}

function extractQuestionText(lines) {
  const optionRegex = /^\s*[(\[]?([A-D])[)\].:\-]?\s+(.+)$/i;
  const answerRegex = /^\s*(answer|ans|correct\s*answer)\s*[:\-]\s*(.+)$/i;

  const questionLines = [];
  for (const line of lines) {
    if (optionRegex.test(line) || answerRegex.test(line)) {
      break;
    }
    questionLines.push(line);
  }

  return normalizeMathDelimiters(questionLines.join('\n').trim());
}

function buildWarnings(mathpixResponse, lines, questionText, options) {
  const warnings = [];

  const confidence = Number(mathpixResponse.confidence || 0);
  if (confidence > 0 && confidence < 0.85) {
    warnings.push('Overall OCR confidence is low. Review equations carefully.');
  }

  if (!questionText) {
    warnings.push('Question text could not be confidently extracted.');
  }

  if (options.length > 0 && options.some((option) => !option)) {
    warnings.push('Some MCQ options are missing. Please review and complete all options.');
  }

  if (lines.length <= 1) {
    warnings.push('Very little text was extracted. Check image quality and crop to a single question.');
  }

  return warnings;
}

function toDraft(mathpixResponse) {
  const rawText = normalizeMathDelimiters(mathpixResponse.text || '');
  const lines = rawText
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean);

  const options = parseOptions(lines);
  const questionText = extractQuestionText(lines);
  const correctAnswer = parseAnswer(lines, options);

  const isMcq = options.filter(Boolean).length >= 2;
  const format = isMcq ? 'MCQ' : 'short_answer';

  const warnings = buildWarnings(mathpixResponse, lines, questionText, options);

  return {
    format,
    questionText,
    options: isMcq ? options : ['', '', '', ''],
    correctAnswer: correctAnswer || '',
    answerVariations: [],
    dragItems: [],
    correctOrder: '',
    explanation: '',
    warnings,
    confidence: Number(mathpixResponse.confidence || 0),
    rawText,
  };
}

async function extractDraftFromMathpix(imageUrl) {
  const appId = process.env.MATHPIX_APP_ID;
  const appKey = process.env.MATHPIX_APP_KEY;

  if (!appId || !appKey) {
    throw new Error('Mathpix credentials are not configured. Set MATHPIX_APP_ID and MATHPIX_APP_KEY.');
  }

  const response = await fetch('https://api.mathpix.com/v3/text', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      app_id: appId,
      app_key: appKey,
    },
    body: JSON.stringify({
      src: imageUrl,
      formats: ['text'],
      math_inline_delimiters: ['$', '$'],
      include_line_data: true,
      rm_spaces: true,
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Mathpix request failed (${response.status}): ${errorBody}`);
  }

  const json = await response.json();
  return toDraft(json);
}

module.exports = {
  extractDraftFromMathpix,
};
