<?php if (!empty($description)) { ?>
<div class="well well-sm zerokyc-payment-description" style="margin-bottom: 15px;">
  <p style="margin: 0;"><?php echo htmlspecialchars($description, ENT_QUOTES, 'UTF-8'); ?></p>
</div>
<?php } ?>
<div id="zerokyc-checkout-error" class="alert alert-danger" style="display: none;"></div>
<div class="buttons">
  <div class="pull-right">
    <input type="button" value="<?php echo htmlspecialchars($button_confirm, ENT_QUOTES, 'UTF-8'); ?>" id="button-confirm" data-loading-text="<?php echo htmlspecialchars($text_loading, ENT_QUOTES, 'UTF-8'); ?>" class="btn btn-primary" />
  </div>
</div>
<script type="text/javascript"><!--
(function($) {
  var isSubmitting = false;
  $('#button-confirm').off('click').on('click', function(e) {
    e.preventDefault();
    if (isSubmitting) {
      return;
    }
    isSubmitting = true;

    var $btn = $('#button-confirm');
    var $err = $('#zerokyc-checkout-error');
    $err.hide().empty();

    $.ajax({
      url: '<?php echo $send_url; ?>',
      type: 'POST',
      dataType: 'json',
      beforeSend: function() {
        $btn.prop('disabled', true);
        if ($.fn.button) {
          $btn.button('loading');
        }
      },
      success: function(json) {
        if (json && json.redirect) {
          window.location.href = json.redirect;
          return;
        }
        isSubmitting = false;
        $btn.prop('disabled', false);
        if ($.fn.button) {
          $btn.button('reset');
        }
        var msg = (json && json.error) ? json.error : 'Payment initialization error.';
        $err.text(msg).show();
      },
      error: function() {
        isSubmitting = false;
        $btn.prop('disabled', false);
        if ($.fn.button) {
          $btn.button('reset');
        }
        $err.text('Network error. Please try again.').show();
      }
    });
  });
})(window.jQuery);
//--></script>
