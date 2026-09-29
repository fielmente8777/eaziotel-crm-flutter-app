class WhatsappTemplateResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final TemplateRequest? request;
  final TemplateResult? result;

  WhatsappTemplateResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.result,
  });

  factory WhatsappTemplateResponse.fromJson(Map<String, dynamic> json) {
    return WhatsappTemplateResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: json['request'] != null
          ? TemplateRequest.fromJson(
              json['request'] as Map<String, dynamic>,
            )
          : null,
      result: json['result'] != null
          ? TemplateResult.fromJson(
              json['result'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'result': result?.toJson(),
    };
  }
}

class TemplateRequest {
  final String? method;
  final String? basesurl;
  final String? endpoint;

  TemplateRequest({
    this.method,
    this.basesurl,
    this.endpoint,
  });

  factory TemplateRequest.fromJson(Map<String, dynamic> json) {
    return TemplateRequest(
      method: json['method'] as String?,
      basesurl: json['basesurl'] as String?,
      endpoint: json['endpoint'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'basesurl': basesurl,
      'endpoint': endpoint,
    };
  }
}

class TemplateResult {
  final TemplateDocs? docs;
  final TemplatePaging? paging;

  TemplateResult({
    this.docs,
    this.paging,
  });

  factory TemplateResult.fromJson(Map<String, dynamic> json) {
    return TemplateResult(
      docs: json['docs'] != null
          ? TemplateDocs.fromJson(
              json['docs'] as Map<String, dynamic>,
            )
          : null,
      paging: json['paging'] != null
          ? TemplatePaging.fromJson(
              json['paging'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docs': docs?.toJson(),
      'paging': paging?.toJson(),
    };
  }
}

class TemplateDocs {
  final List<WhatsappTemplate>? data;

  TemplateDocs({
    this.data,
  });

  factory TemplateDocs.fromJson(Map<String, dynamic> json) {
    return TemplateDocs(
      data: (json['data'] as List?)
          ?.map(
            (e) => WhatsappTemplate.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class WhatsappTemplate {
  final String? name;
  final String? previousCategory;
  final String? parameterFormat;
  final List<TemplateComponent>? components;
  final String? language;
  final String? status;
  final String? category;
  final String? subCategory;
  final bool? disableIosAutofill;
  final bool? isPrimaryDeviceDeliveryOnly;
  final String? id;
  final int? messageSendTtlSeconds;

  WhatsappTemplate({
    this.name,
    this.previousCategory,
    this.parameterFormat,
    this.components,
    this.language,
    this.status,
    this.category,
    this.subCategory,
    this.disableIosAutofill,
    this.isPrimaryDeviceDeliveryOnly,
    this.id,
    this.messageSendTtlSeconds,
  });

  factory WhatsappTemplate.fromJson(Map<String, dynamic> json) {
    return WhatsappTemplate(
      name: json['name'] as String?,
      previousCategory: json['previous_category'] as String?,
      parameterFormat: json['parameter_format'] as String?,
      components: (json['components'] as List?)
          ?.map(
            (e) => TemplateComponent.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      language: json['language'] as String?,
      status: json['status'] as String?,
      category: json['category'] as String?,
      subCategory: json['sub_category'] as String?,
      disableIosAutofill: json['disable_ios_autofill'] as bool?,
      isPrimaryDeviceDeliveryOnly:
          json['is_primary_device_delivery_only'] as bool?,
      id: json['id'] as String?,
      messageSendTtlSeconds:
          json['message_send_ttl_seconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'previous_category': previousCategory,
      'parameter_format': parameterFormat,
      'components': components?.map((e) => e.toJson()).toList(),
      'language': language,
      'status': status,
      'category': category,
      'sub_category': subCategory,
      'disable_ios_autofill': disableIosAutofill,
      'is_primary_device_delivery_only': isPrimaryDeviceDeliveryOnly,
      'id': id,
      'message_send_ttl_seconds': messageSendTtlSeconds,
    };
  }
}

class TemplateComponent {
  final String? type;
  final String? format;
  final String? text;
  final TemplateExample? example;
  final List<TemplateButton>? buttons;
  final bool? addSecurityRecommendation;
  final int? codeExpirationMinutes;

  TemplateComponent({
    this.type,
    this.format,
    this.text,
    this.example,
    this.buttons,
    this.addSecurityRecommendation,
    this.codeExpirationMinutes,
  });

  factory TemplateComponent.fromJson(Map<String, dynamic> json) {
    return TemplateComponent(
      type: json['type'] as String?,
      format: json['format'] as String?,
      text: json['text'] as String?,
      example: json['example'] != null
          ? TemplateExample.fromJson(
              json['example'] as Map<String, dynamic>,
            )
          : null,
      buttons: (json['buttons'] as List?)
          ?.map(
            (e) => TemplateButton.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      addSecurityRecommendation:
          json['add_security_recommendation'] as bool?,
      codeExpirationMinutes:
          json['code_expiration_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'format': format,
      'text': text,
      'example': example?.toJson(),
      'buttons': buttons?.map((e) => e.toJson()).toList(),
      'add_security_recommendation': addSecurityRecommendation,
      'code_expiration_minutes': codeExpirationMinutes,
    };
  }
}

class TemplateExample {
  final List<List<String>>? bodyText;
  final List<String>? headerText;
  final List<String>? headerHandle;

  TemplateExample({
    this.bodyText,
    this.headerText,
    this.headerHandle,
  });

  factory TemplateExample.fromJson(Map<String, dynamic> json) {
    return TemplateExample(
      bodyText: (json['body_text'] as List?)
          ?.map(
            (e) => (e as List?)
                    ?.map((item) => item.toString())
                    .toList() ??
                <String>[],
          )
          .toList(),
      headerText: (json['header_text'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      headerHandle: (json['header_handle'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body_text': bodyText,
      'header_text': headerText,
      'header_handle': headerHandle,
    };
  }
}

class TemplateButton {
  final String? type;
  final String? text;
  final String? url;
  final List<String>? example;

  TemplateButton({
    this.type,
    this.text,
    this.url,
    this.example,
  });

  factory TemplateButton.fromJson(Map<String, dynamic> json) {
    return TemplateButton(
      type: json['type'] as String?,
      text: json['text'] as String?,
      url: json['url'] as String?,
      example: (json['example'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'url': url,
      'example': example,
    };
  }
}

class TemplatePaging {
  final TemplateCursors? cursors;

  TemplatePaging({
    this.cursors,
  });

  factory TemplatePaging.fromJson(Map<String, dynamic> json) {
    return TemplatePaging(
      cursors: json['cursors'] != null
          ? TemplateCursors.fromJson(
              json['cursors'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cursors': cursors?.toJson(),
    };
  }
}

class TemplateCursors {
  final String? before;
  final String? after;

  TemplateCursors({
    this.before,
    this.after,
  });

  factory TemplateCursors.fromJson(Map<String, dynamic> json) {
    return TemplateCursors(
      before: json['before'] as String?,
      after: json['after'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'before': before,
      'after': after,
    };
  }
}