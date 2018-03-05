FROM node:alpine

COPY ocr.js /
COPY package.json /
COPY package-lock.json /
RUN apk --update --no-cache --virtual wget-deps add ca-certificates openssl && \
    apk --no-cache add tesseract-ocr git && \
    wget -q -P /usr/share/tessdata/ https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata && \
    apk del wget-deps && \
    npm install

EXPOSE 3001

CMD ["node", "ocr.js"]
