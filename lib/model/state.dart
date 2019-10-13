import 'package:flutter/material.dart';

enum ScrapmediaServices { openDBAPI, awsAPI }

class StateModel {

  final TextEditingController awsAccessKeyIdController;
  final TextEditingController awsSecretAccessKeyController;
  final TextEditingController awsAssociateTagController;
  final TextEditingController scrapboxProjectNameController;
  final TextEditingController bitlyApiKeyController;
  final ScrapmediaServices service;

  StateModel({
    this.awsAccessKeyIdController,
    this.awsSecretAccessKeyController,
    this.awsAssociateTagController,
    this.scrapboxProjectNameController,
    this.bitlyApiKeyController,
    this.service = ScrapmediaServices.openDBAPI,
  });
}