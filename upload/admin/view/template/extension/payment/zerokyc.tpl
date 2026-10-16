<?php echo $header; ?><?php echo $column_left; ?>
<div id="content">
  <div class="page-header">
    <div class="container-fluid">
      <div class="pull-right">
        <button type="submit" form="form-zerokyc" data-toggle="tooltip" title="<?php echo $button_save; ?>" class="btn btn-primary"><i class="fa fa-save"></i></button>
        <a href="<?php echo $cancel; ?>" data-toggle="tooltip" title="<?php echo $button_cancel; ?>" class="btn btn-default"><i class="fa fa-reply"></i></a>
      </div>
      <h1><?php echo $heading_title; ?></h1>
      <ul class="breadcrumb">
        <?php foreach ($breadcrumbs as $breadcrumb) { ?>
        <li><a href="<?php echo $breadcrumb['href']; ?>"><?php echo $breadcrumb['text']; ?></a></li>
        <?php } ?>
      </ul>
    </div>
  </div>
  <div class="container-fluid">
    <?php if ($error_warning) { ?>
    <div class="alert alert-danger"><i class="fa fa-exclamation-circle"></i> <?php echo $error_warning; ?>
      <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
    <?php } ?>
    <?php if (!$is_supported_fiat) { ?>
    <div class="alert alert-warning"><i class="fa fa-exclamation-triangle"></i> <?php echo sprintf($text_currency_notice, htmlspecialchars($store_currency, ENT_QUOTES, 'UTF-8'), htmlspecialchars($supported_fiat_currencies, ENT_QUOTES, 'UTF-8')); ?></div>
    <?php } ?>
    <div class="panel panel-default">
      <div class="panel-heading">
        <h3 class="panel-title"><i class="fa fa-pencil"></i> <?php echo $text_edit; ?></h3>
      </div>
      <div class="panel-body">
        <form action="<?php echo $action; ?>" method="post" enctype="multipart/form-data" id="form-zerokyc" class="form-horizontal">
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-status"><?php echo $entry_status; ?></label>
            <div class="col-sm-10">
              <select name="zerokyc_status" id="input-status" class="form-control">
                <?php if ($zerokyc_status) { ?>
                <option value="1" selected="selected"><?php echo $text_enabled; ?></option>
                <option value="0"><?php echo $text_disabled; ?></option>
                <?php } else { ?>
                <option value="1"><?php echo $text_enabled; ?></option>
                <option value="0" selected="selected"><?php echo $text_disabled; ?></option>
                <?php } ?>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-title"><?php echo $entry_title; ?></label>
            <div class="col-sm-10">
              <input type="text" name="zerokyc_title" value="<?php echo htmlspecialchars($zerokyc_title, ENT_QUOTES, 'UTF-8'); ?>" id="input-title" class="form-control" />
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-description"><?php echo $entry_description; ?></label>
            <div class="col-sm-10">
              <textarea name="zerokyc_description" rows="2" id="input-description" class="form-control"><?php echo htmlspecialchars($zerokyc_description, ENT_QUOTES, 'UTF-8'); ?></textarea>
            </div>
          </div>

          <div class="form-group required">
            <label class="col-sm-2 control-label" for="input-api-key"><span data-toggle="tooltip" title="<?php echo htmlspecialchars($help_api_key, ENT_QUOTES, 'UTF-8'); ?>"><?php echo $entry_api_key; ?></span></label>
            <div class="col-sm-10">
              <div class="input-group">
                <input type="password" name="zerokyc_api_key" value="<?php echo htmlspecialchars($zerokyc_api_key, ENT_QUOTES, 'UTF-8'); ?>" placeholder="pk_live_... / pk_test_..." id="input-api-key" class="form-control" autocomplete="off" />
                <span class="input-group-btn">
                  <button type="button" id="button-zerokyc-ping" class="btn btn-info"><i class="fa fa-plug"></i> <?php echo $button_ping; ?></button>
                </span>
              </div>
              <div id="zerokyc-ping-result" style="margin-top: 6px; display: none;"></div>
              <?php if ($error_api_key) { ?>
              <div class="text-danger"><?php echo $error_api_key; ?></div>
              <?php } ?>
            </div>
          </div>

          <div class="form-group required">
            <label class="col-sm-2 control-label" for="input-webhook-secret"><span data-toggle="tooltip" title="<?php echo htmlspecialchars($help_webhook_secret, ENT_QUOTES, 'UTF-8'); ?>"><?php echo $entry_webhook_secret; ?></span></label>
            <div class="col-sm-10">
              <input type="password" name="zerokyc_webhook_secret" value="<?php echo htmlspecialchars($zerokyc_webhook_secret, ENT_QUOTES, 'UTF-8'); ?>" placeholder="whsec_..." id="input-webhook-secret" class="form-control" autocomplete="off" />
              <?php if ($error_webhook_secret) { ?>
              <div class="text-danger"><?php echo $error_webhook_secret; ?></div>
              <?php } ?>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-webhook-url"><span data-toggle="tooltip" title="<?php echo htmlspecialchars($help_webhook_url, ENT_QUOTES, 'UTF-8'); ?>"><?php echo $entry_webhook_url; ?></span></label>
            <div class="col-sm-10">
              <div class="input-group">
                <input type="text" value="<?php echo htmlspecialchars($webhook_url, ENT_QUOTES, 'UTF-8'); ?>" id="input-webhook-url" class="form-control" readonly="readonly" />
                <span class="input-group-btn">
                  <button type="button" class="btn btn-default zerokyc-copy-btn" data-target="#input-webhook-url"><i class="fa fa-clipboard"></i> <?php echo $button_copy; ?></button>
                </span>
              </div>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-cron-url"><span data-toggle="tooltip" title="<?php echo htmlspecialchars($help_cron_url, ENT_QUOTES, 'UTF-8'); ?>"><?php echo $entry_cron_url; ?></span></label>
            <div class="col-sm-10">
              <div class="input-group">
                <input type="text" value="<?php echo htmlspecialchars($cron_url, ENT_QUOTES, 'UTF-8'); ?>" id="input-cron-url" class="form-control" readonly="readonly" />
                <span class="input-group-btn">
                  <button type="button" class="btn btn-default zerokyc-copy-btn" data-target="#input-cron-url"><i class="fa fa-clipboard"></i> <?php echo $button_copy; ?></button>
                </span>
              </div>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-payment-currency"><span data-toggle="tooltip" title="<?php echo htmlspecialchars($help_payment_currency, ENT_QUOTES, 'UTF-8'); ?>"><?php echo $entry_payment_currency; ?></span></label>
            <div class="col-sm-10">
              <select name="zerokyc_payment_currency" id="input-payment-currency" class="form-control">
                <?php foreach ($payment_currencies as $code => $label) { ?>
                <option value="<?php echo htmlspecialchars($code, ENT_QUOTES, 'UTF-8'); ?>" <?php echo ($zerokyc_payment_currency === $code) ? 'selected="selected"' : ''; ?>><?php echo htmlspecialchars($label, ENT_QUOTES, 'UTF-8'); ?></option>
                <?php } ?>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-ttl-minutes"><span data-toggle="tooltip" title="<?php echo htmlspecialchars($help_ttl_minutes, ENT_QUOTES, 'UTF-8'); ?>"><?php echo $entry_ttl_minutes; ?></span></label>
            <div class="col-sm-10">
              <input type="number" name="zerokyc_ttl_minutes" value="<?php echo (int) $zerokyc_ttl_minutes; ?>" min="5" max="1440" id="input-ttl-minutes" class="form-control" />
              <?php if ($error_ttl_minutes) { ?>
              <div class="text-danger"><?php echo $error_ttl_minutes; ?></div>
              <?php } ?>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-auto-cancel"><span data-toggle="tooltip" title="<?php echo htmlspecialchars($help_auto_cancel, ENT_QUOTES, 'UTF-8'); ?>"><?php echo $entry_auto_cancel; ?></span></label>
            <div class="col-sm-10">
              <select name="zerokyc_auto_cancel" id="input-auto-cancel" class="form-control">
                <option value="1" <?php echo ($zerokyc_auto_cancel) ? 'selected="selected"' : ''; ?>><?php echo $text_yes; ?></option>
                <option value="0" <?php echo (!$zerokyc_auto_cancel) ? 'selected="selected"' : ''; ?>><?php echo $text_no; ?></option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-double-check"><span data-toggle="tooltip" title="<?php echo htmlspecialchars($help_double_check, ENT_QUOTES, 'UTF-8'); ?>"><?php echo $entry_double_check; ?></span></label>
            <div class="col-sm-10">
              <select name="zerokyc_double_check" id="input-double-check" class="form-control">
                <option value="1" <?php echo ($zerokyc_double_check) ? 'selected="selected"' : ''; ?>><?php echo $text_yes; ?></option>
                <option value="0" <?php echo (!$zerokyc_double_check) ? 'selected="selected"' : ''; ?>><?php echo $text_no; ?></option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-debug"><span data-toggle="tooltip" title="<?php echo htmlspecialchars($help_debug, ENT_QUOTES, 'UTF-8'); ?>"><?php echo $entry_debug; ?></span></label>
            <div class="col-sm-10">
              <select name="zerokyc_debug" id="input-debug" class="form-control">
                <option value="1" <?php echo ($zerokyc_debug) ? 'selected="selected"' : ''; ?>><?php echo $text_yes; ?></option>
                <option value="0" <?php echo (!$zerokyc_debug) ? 'selected="selected"' : ''; ?>><?php echo $text_no; ?></option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-total"><span data-toggle="tooltip" title="<?php echo htmlspecialchars($help_total, ENT_QUOTES, 'UTF-8'); ?>"><?php echo $entry_total; ?></span></label>
            <div class="col-sm-10">
              <input type="text" name="zerokyc_total" value="<?php echo htmlspecialchars($zerokyc_total, ENT_QUOTES, 'UTF-8'); ?>" placeholder="0.00" id="input-total" class="form-control" />
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-pending-status"><?php echo $entry_pending_status; ?></label>
            <div class="col-sm-10">
              <select name="zerokyc_pending_status_id" id="input-pending-status" class="form-control">
                <?php foreach ($order_statuses as $order_status) { ?>
                <option value="<?php echo (int) $order_status['order_status_id']; ?>" <?php echo ((int) $order_status['order_status_id'] === (int) $zerokyc_pending_status_id) ? 'selected="selected"' : ''; ?>><?php echo htmlspecialchars($order_status['name'], ENT_QUOTES, 'UTF-8'); ?></option>
                <?php } ?>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-confirming-status"><?php echo $entry_confirming_status; ?></label>
            <div class="col-sm-10">
              <select name="zerokyc_confirming_status_id" id="input-confirming-status" class="form-control">
                <?php foreach ($order_statuses as $order_status) { ?>
                <option value="<?php echo (int) $order_status['order_status_id']; ?>" <?php echo ((int) $order_status['order_status_id'] === (int) $zerokyc_confirming_status_id) ? 'selected="selected"' : ''; ?>><?php echo htmlspecialchars($order_status['name'], ENT_QUOTES, 'UTF-8'); ?></option>
                <?php } ?>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-paid-status"><?php echo $entry_paid_status; ?></label>
            <div class="col-sm-10">
              <select name="zerokyc_paid_status_id" id="input-paid-status" class="form-control">
                <?php foreach ($order_statuses as $order_status) { ?>
                <option value="<?php echo (int) $order_status['order_status_id']; ?>" <?php echo ((int) $order_status['order_status_id'] === (int) $zerokyc_paid_status_id) ? 'selected="selected"' : ''; ?>><?php echo htmlspecialchars($order_status['name'], ENT_QUOTES, 'UTF-8'); ?></option>
                <?php } ?>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-underpaid-status"><?php echo $entry_underpaid_status; ?></label>
            <div class="col-sm-10">
              <select name="zerokyc_underpaid_status_id" id="input-underpaid-status" class="form-control">
                <?php foreach ($order_statuses as $order_status) { ?>
                <option value="<?php echo (int) $order_status['order_status_id']; ?>" <?php echo ((int) $order_status['order_status_id'] === (int) $zerokyc_underpaid_status_id) ? 'selected="selected"' : ''; ?>><?php echo htmlspecialchars($order_status['name'], ENT_QUOTES, 'UTF-8'); ?></option>
                <?php } ?>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-expired-status"><?php echo $entry_expired_status; ?></label>
            <div class="col-sm-10">
              <select name="zerokyc_expired_status_id" id="input-expired-status" class="form-control">
                <?php foreach ($order_statuses as $order_status) { ?>
                <option value="<?php echo (int) $order_status['order_status_id']; ?>" <?php echo ((int) $order_status['order_status_id'] === (int) $zerokyc_expired_status_id) ? 'selected="selected"' : ''; ?>><?php echo htmlspecialchars($order_status['name'], ENT_QUOTES, 'UTF-8'); ?></option>
                <?php } ?>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-geo-zone"><?php echo $entry_geo_zone; ?></label>
            <div class="col-sm-10">
              <select name="zerokyc_geo_zone_id" id="input-geo-zone" class="form-control">
                <option value="0"><?php echo $text_all_zones; ?></option>
                <?php foreach ($geo_zones as $geo_zone) { ?>
                <option value="<?php echo (int) $geo_zone['geo_zone_id']; ?>" <?php echo ((int) $geo_zone['geo_zone_id'] === (int) $zerokyc_geo_zone_id) ? 'selected="selected"' : ''; ?>><?php echo htmlspecialchars($geo_zone['name'], ENT_QUOTES, 'UTF-8'); ?></option>
                <?php } ?>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-sort-order"><?php echo $entry_sort_order; ?></label>
            <div class="col-sm-10">
              <input type="text" name="zerokyc_sort_order" value="<?php echo (int) $zerokyc_sort_order; ?>" placeholder="1" id="input-sort-order" class="form-control" />
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
<script type="text/javascript"><!--
(function($) {
  $('#button-zerokyc-ping').on('click', function() {
    var $btn = $(this);
    var $res = $('#zerokyc-ping-result');
    $btn.prop('disabled', true);
    $res.show().attr('class', 'text-info').text('<?php echo addslashes($text_testing); ?>');

    $.ajax({
      url: '<?php echo $ping_url; ?>',
      type: 'POST',
      dataType: 'json',
      data: {
        api_key: $('#input-api-key').val()
      },
      success: function(json) {
        if (json && json.ok) {
          $res.attr('class', 'text-success').html('<i class="fa fa-check-circle"></i> ' + $('<div>').text(json.message).html());
        } else {
          var msg = (json && json.message) ? json.message : 'Error';
          $res.attr('class', 'text-danger').html('<i class="fa fa-exclamation-circle"></i> ' + $('<div>').text(msg).html());
        }
      },
      error: function(xhr) {
        $res.attr('class', 'text-danger').text('HTTP Error ' + xhr.status);
      },
      complete: function() {
        $btn.prop('disabled', false);
      }
    });
  });

  $('.zerokyc-copy-btn').on('click', function() {
    var $btn = $(this);
    var target = $btn.attr('data-target');
    var $input = $(target);
    if ($input.length) {
      $input[0].select();
      try {
        document.execCommand('copy');
        var origHtml = $btn.html();
        $btn.html('<i class="fa fa-check"></i> <?php echo addslashes($text_copied); ?>');
        setTimeout(function() {
          $btn.html(origHtml);
        }, 1500);
      } catch (e) {}
    }
  });
})(window.jQuery);
//--></script>
<?php echo $footer; ?>
