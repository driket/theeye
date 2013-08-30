class Probe < ActiveRecord::Base

  has_many :widgets
  accepts_nested_attributes_for :widgets, :allow_destroy => true
  
  STATUS = {
    'ok'            => 0,
    'alert'         => 1,
    'warning'       => 2,
    'unresponsive'  => 3,
  }
  
  def health
    total_health = 0
    for widget in widgets
      total_health += 1 if widget.status == STATUS['ok'] || widget.status == STATUS['warning']
    end
    (widgets.size>0)?(total_health / widgets.size * 100):100
  end
  
  def Probe.global_health
    global_health = 0
    for probe in Probe.all
      global_health += probe.health
      logger.debug probe.health
    end
    global_health / Probe.all.size
  end
  
end
