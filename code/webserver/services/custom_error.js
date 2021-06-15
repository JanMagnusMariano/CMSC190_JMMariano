function CustomError(message, code) {
	this.name = 'CustomError';
	this.message = message || 'Error';
	this.code = code;
}

CustomError.prototype = Object.create(Error.prototype);
CustomError.prototype.constructor = CustomError;

module.exports = CustomError;
